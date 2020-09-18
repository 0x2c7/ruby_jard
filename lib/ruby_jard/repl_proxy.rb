# frozen_string_literal: true

require 'pty'
require 'ruby_jard/pager'

module RubyJard
  ##
  # A wrapper to wrap around Pry instance.
  #
  # Pry depends heavily on GNU Readline, or any Readline-like input libraries. Those libraries
  # serve limited use cases, and specific interface to support those. Unfortunately, to serve
  # Jard's keyboard functionalities, those libraries must support individual keyboard events,
  # programmatically input control, etc. Ruby's GNU Readline binding obviously doesn't support
  # those fancy features. Other pure-ruby implementation such as coolline, tty-reader is not
  # a perfit fit, while satisfying performance and boringly stablility of GNU Readline. Indeed,
  # while testing those libraries, I meet some weird quirks, lagging, cursor jumping around.
  # Putting efforts in a series of monkey patches help a little bit, but it harms in long-term.
  # Re-implementing is just like jumping into another rabbit hole.
  #
  # That's why I come up with another approach:
  # - Create a proxy wrapping around pry instance, so that it reads characters one by one, in
  # *raw* mode
  # - Keyboard combinations are captured and handled before piping the rest to the pry instance
  # - The proxy interacts with Pry's REPL loop via Pry hooks (Thank God) to seamlessly switch
  # between *raw* mode and *cooked* mode while Pry interacts with TTY.
  # - Control flow instructions are threw out, and captured by ReplProcessor.
  #
  # As a result, Jard may support key-binding customization without breaking pry functionalities.
  class ReplProxy
    # Some commands overlaps with Jard, Ruby, and even cause confusion for
    # users. It's better ignore or re-implement those commands.
    PRY_EXCLUDED_COMMANDS = [
      'pry-backtrace', # Redundant method for normal user
      'watch',         # Conflict with byebug and jard watch
      'edit',          # Sorry, but a file should not be editted while debugging, as it made breakpoints shifted
      'play',          # What if the played files or methods include jard again?
      'stat',          # Included in jard UI
      'backtrace',     # Re-implemented later
      'break',         # Re-implemented later
      'exit-all',      # Conflicted with continue
      'exit-program',  # We already have `exit` native command
      '!pry',          # No need to complicate things
      'jump-to',       # No need to complicate things
      'nesting',       # No need to complicate things
      'switch-to',     # No need to complicate things
      'disable-pry'    # No need to complicate things
    ].freeze

    INTERNAL_KEY_BINDINGS = {
      RubyJard::Keys::CTRL_C => (KEY_BINDING_INTERRUPT = :interrupt)
    }.freeze

    KEY_READ_TIMEOUT = 0.2           # 200ms
    PTY_OUTPUT_TIMEOUT = 1.to_f / 60 # 60hz

    ##
    # A tool to communicate between functional threads and main threads
    class FlowInterrupt < StandardError
      attr_reader :flow

      def initialize(msg = '', flow = nil)
        super(msg)
        @flow = flow
      end
    end

    ##
    # A class to store the state with multi-thread guarding
    # Ready => Processing/Exiting
    # Processing => Ready again
    # Exiting => Exited
    # Exited => Ready
    class ReplState
      STATES = [
        STATE_READY      = 0,
        STATE_EXITING    = 1,
        STATE_PROCESSING = 2,
        STATE_EXITED     = 3
      ].freeze
      def initialize
        @state = STATE_EXITED
        @mutex = Mutex.new
      end

      def check(method_name)
        @mutex.synchronize { yield if send(method_name) }
      end

      def ready?
        @state == STATE_READY
      end

      def ready!
        if ready? || processing? || exited?
          @mutex.synchronize { @state = STATE_READY }
        end
      end

      def processing?
        @state == STATE_PROCESSING
      end

      def processing!
        return unless ready?

        @mutex.synchronize { @state = STATE_PROCESSING }
      end

      def exiting?
        @state == STATE_EXITING
      end

      def exiting!
        @mutex.synchronize { @state = STATE_EXITING }
      end

      def exited?
        @state == STATE_EXITED
      end

      def exited!
        @mutex.synchronize { @state = STATE_EXITED }
      end
    end

    def initialize(key_bindings: nil, input: RubyJard::Console.input, output: RubyJard::Console.output)
      @input = input
      @output = output

      @state = ReplState.new

      @pry_input_pipe_read, @pry_input_pipe_write = IO.pipe
      @pry_output_pty_read, @pry_output_pty_write = PTY.open
      @pry = pry_instance

      @key_bindings = key_bindings || RubyJard::KeyBindings.new
      INTERNAL_KEY_BINDINGS.each do |sequence, action|
        @key_bindings.push(sequence, action)
      end

      @pry_pty_output_thread = Thread.new { pry_pty_output }
      @pry_pty_output_thread.name = '<<Jard: Pty Output Thread>>'

      Signal.trap('SIGWINCH') do
        @main_thread.raise FlowInterrupt.new('Resize event', RubyJard::ControlFlow.new(:list))
      end
    end

    def repl(current_binding)
      @state.ready!
      @openning_pager = false

      RubyJard::Console.disable_echo!(@output)
      RubyJard::Console.raw!(@output)

      Readline.input = @pry_input_pipe_read
      Readline.output = @pry_output_pty_write
      @pry.binding_stack.clear

      @main_thread = Thread.current

      @pry_input_thread = Thread.new { pry_repl(current_binding) }
      @pry_input_thread.abort_on_exception = true
      @pry_input_thread.report_on_exception = false
      @pry_input_thread.name = '<<Jard: Pry input thread >>'

      @key_listen_thread = Thread.new { listen_key_press }
      @key_listen_thread.abort_on_exception = true
      @key_listen_thread.report_on_exception = false
      @key_listen_thread.name = '<<Jard: Repl key listen >>'

      [@pry_input_thread, @key_listen_thread].map(&:join)
    rescue FlowInterrupt => e
      @state.exiting!
      sleep PTY_OUTPUT_TIMEOUT until @state.exited?
      RubyJard::ControlFlow.dispatch(e.flow)
    ensure
      RubyJard::Console.enable_echo!(@output)
      RubyJard::Console.cooked!(@output)
      Readline.input = @input
      Readline.output = @output
      @key_listen_thread&.exit if @key_listen_thread&.alive?
      @pry_input_thread&.exit if @pry_input_thread&.alive?
      @state.exited!
    end

    private

    def read_key
      RubyJard::Console.getch(@input, KEY_READ_TIMEOUT)
    end

    def pry_pty_output
      loop do
        if @state.exiting?
          if @pry_output_pty_read.ready?
            write_output(@pry_output_pty_read.read_nonblock(2048))
          else
            @state.exited!
          end
        elsif @state.exited?
          sleep PTY_OUTPUT_TIMEOUT
        else
          content = @pry_output_pty_read.read_nonblock(2048)
          unless content.nil?
            write_output(content)
          end
        end
      rescue IO::WaitReadable, IO::WaitWritable
        # Retry
        sleep PTY_OUTPUT_TIMEOUT
      end
    end

    def pry_repl(current_binding)
      flow = RubyJard::ControlFlow.listen do
        @pry.repl(current_binding)
      end
      @state.check(:ready?) do
        @main_thread.raise FlowInterrupt.new('Interrupt from repl thread', flow)
      end
    end

    def listen_key_press
      loop do
        break if @state.exiting? || @state.exited?

        if @state.processing? && @openning_pager
          # Discard all keys unfortunately
          sleep PTY_OUTPUT_TIMEOUT
        else
          key = @key_bindings.match { read_key }
          if key.is_a?(RubyJard::KeyBinding)
            continue = handle_key_binding(key)
            break unless continue
          elsif !key.empty?
            @pry_input_pipe_write.write(key)
          end
        end
      end
    end

    def handle_key_binding(key_binding)
      case key_binding.action
      when KEY_BINDING_INTERRUPT
        handle_interrupt_command
        true
      else
        flow = RubyJard::ControlFlow.new(:key_binding, action: key_binding.action)
        @state.check(:ready?) do
          @main_thread.raise FlowInterrupt.new('Interrupt from repl thread', flow)
        end
        false
      end
    end

    def handle_interrupt_command
      @state.check(:ready?) do
        @pry_input_thread&.raise Interrupt if @pry_input_thread&.alive?
      end
      loop do
        begin
          sleep PTY_OUTPUT_TIMEOUT
        rescue Interrupt
          # Interrupt spam. Ignore.
        end
        break unless @pry_input_thread&.pending_interrupt?
      end
    end

    def pry_instance
      pry_instance = Pry.new(
        prompt: pry_jard_prompt,
        quiet: true,
        commands: pry_command_set,
        hooks: pry_hooks,
        output: @pry_output_pty_write
      )
      # I'll be burned in hell for this
      # TODO: Contact pry author to add :after_handle_line hook
      class << pry_instance
        def _jard_handle_line(*args)
          _original_handle_line(*args)
          exec_hook :after_handle_line, *args, self
        end
        alias_method :_original_handle_line, :handle_line
        alias_method :handle_line, :_jard_handle_line

        def pager
          RubyJard::Pager.new(self)
        end
      end
      pry_instance
    end

    def pry_command_set
      set = Pry::CommandSet.new
      set.import_from(
        Pry.config.commands,
        *(Pry.config.commands.list_commands - PRY_EXCLUDED_COMMANDS)
      )
      set
    end

    def pry_jard_prompt
      Pry::Prompt.new(
        :jard,
        'Custom pry promt for Jard', [
          proc do |_context, _nesting, _pry_instance|
            'jard >> '
          end,
          proc do |_context, _nesting, _pry_instance|
            'jard *> '
          end
        ]
      )
    end

    def pry_hooks
      hooks = Pry::Hooks.default
      hooks.add_hook(:after_read, :jard_proxy_acquire_lock) do |_read_string, _pry|
        RubyJard::Console.cooked!(@output)
        @state.processing!
        # Sleep 2 ticks, wait for pry to print out all existing output in the queue
        sleep PTY_OUTPUT_TIMEOUT * 2
      end
      hooks.add_hook(:after_handle_line, :jard_proxy_release_lock) do
        RubyJard::Console.raw!(@output)
        @state.ready!
      end
      hooks.add_hook(:before_pager, :jard_proxy_before_pager) do
        @openning_pager = true

        @state.processing!
        RubyJard::Console.cooked!(@output)
      end
      hooks.add_hook(:after_pager, :jard_proxy_after_pager) do
        @openning_pager = false
        @state.ready!
        RubyJard::Console.raw!(@output)
      end
    end

    def write_output(content)
      if @output == $stdout
        @output.write content, from_jard: true
      else
        @output.write content
      end
    end
  end
end
