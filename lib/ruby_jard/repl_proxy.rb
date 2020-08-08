# frozen_string_literal: true

require 'pty'

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

    COMMANDS = [
      CMD_FLOW      = :flow,
      CMD_EVALUATE  = :evaluate,
      CMD_EVALUATED = :evaluated,
      CMD_INTERRUPT = :interrupt
    ].freeze
    INTERNAL_KEY_BINDINGS = {
      RubyJard::Keys::END_LINE => (KEY_BINDING_ENDLINE   = :end_line),
      RubyJard::Keys::CTRL_C   => (KEY_BINDING_INTERRUPT = :interrupt)
    }.freeze

    KEY_READ_TIMEOUT = 0.1           # 100ms
    PTY_OUTPUT_TIMEOUT = 1.to_f / 60 # 60hz

    STATES = [
      STATE_READY = 0,
      STATE_EXITING = 1,
      STATE_EXITED = 2
    ].freeze

    def initialize(key_bindings: nil)
      @state = STATE_EXITED

      @pry_input_pipe_read, @pry_input_pipe_write = IO.pipe
      @pry_output_pty_read, @pry_output_pty_write = PTY.open
      @pry = pry_instance
      @pry_commands = Queue.new

      @key_bindings = key_bindings || RubyJard::KeyBindings.new
      INTERNAL_KEY_BINDINGS.each do |sequence, action|
        @key_bindings.push(sequence, action)
      end

      @pry_pty_output_thread = Thread.new { pry_pty_output }
    end

    def repl(current_binding)
      ready!

      RubyJard::Console.disable_echo!

      Readline.input = @pry_input_pipe_read
      Readline.output = @pry_output_pty_write
      @pry_commands.clear
      @pry.binding_stack.clear

      @pry_input_thread = Thread.new { pry_repl(current_binding) }
      @pry_input_thread.report_on_exception = false if @pry_input_thread.respond_to?(:report_on_exception)
      loop do
        break unless ready?

        if @pry_commands.empty?
          listen_key_press
        else
          cmd, value = @pry_commands.deq
          handle_command(cmd, value)
        end
      end
    ensure
      RubyJard::Console.enable_echo!
      Readline.input = STDIN
      Readline.output = STDOUT
      @pry_input_thread&.exit if @pry_input_thread&.alive?

      exited!
    end

    private

    def ready?
      @state == STATE_READY
    end

    def ready!
      @state = STATE_READY
    end

    def exiting?
      @state == STATE_EXITING
    end

    def exiting!
      @state = STATE_EXITING
    end

    def exited?
      @state == STATE_EXITED
    end

    def exited!
      @state = STATE_EXITED
    end

    def read_key
      RubyJard::Console.getch(STDIN, KEY_READ_TIMEOUT)
    end

    def pry_repl(current_binding)
      sleep PTY_OUTPUT_TIMEOUT unless ready?

      flow = RubyJard::ControlFlow.listen do
        @pry.repl(current_binding)
      end
      @pry_commands << [CMD_FLOW, flow]
    rescue StandardError => e
      RubyJard::ScreenManager.draw_error(e)
      raise
    end

    def pry_pty_output
      loop do
        if exiting?
          if @pry_output_pty_read.ready?
            STDOUT.write @pry_output_pty_read.read_nonblock(255), from_jard: true
          else
            exited!
          end
        elsif exited?
          sleep PTY_OUTPUT_TIMEOUT
        else
          STDOUT.write @pry_output_pty_read.read_nonblock(255), from_jard: true
        end
      rescue IO::WaitReadable, IO::WaitWritable
        # Retry
        sleep PTY_OUTPUT_TIMEOUT
      end
    end

    def listen_key_press
      key = @key_bindings.match { read_key }
      if key.is_a?(RubyJard::KeyBinding)
        handle_key_binding(key)
      elsif !key.empty?
        @pry_input_pipe_write.write(key)
      end
    end

    def handle_key_binding(key_binding)
      case key_binding.action
      when KEY_BINDING_ENDLINE
        @pry_input_pipe_write.write(key_binding.sequence)
        @pry_commands << [CMD_EVALUATE]
      when KEY_BINDING_INTERRUPT
        handle_interrupt_command
      else
        handle_flow_command(RubyJard::ControlFlow.new(:key_binding, action: key_binding.action))
      end
    end

    def handle_command(cmd, value)
      case cmd
      when CMD_FLOW
        handle_flow_command(value)
      when CMD_EVALUATE
        loop do
          cmd, value = @pry_commands.deq
          break if [CMD_EVALUATED, CMD_FLOW].include?(cmd)
        end
        handle_command(cmd, value)
      when CMD_EVALUATED
        # Ignore
      end
    end

    def handle_interrupt_command
      @pry_input_thread&.raise Interrupt if @pry_input_thread&.alive?
      loop do
        begin
          sleep PTY_OUTPUT_TIMEOUT
        rescue Interrupt
          # Interrupt spam. Ignore.
        end
        break unless @pry_input_thread&.pending_interrupt?
      end
    end

    def handle_flow_command(flow)
      @pry_commands.clear
      exiting!
      sleep PTY_OUTPUT_TIMEOUT until exited?
      RubyJard::ControlFlow.dispatch(flow)
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
      hooks.add_hook(:after_read, :jard_proxy_acquire_lock) do |read_string, _pry|
        unless Pry::Code.complete_expression?(read_string)
          @pry_commands << [CMD_EVALUATED]
        end
      rescue SyntaxError
        # Ignore
        @pry_commands << [CMD_EVALUATED]
      end
      hooks.add_hook(:after_handle_line, :jard_proxy_release_lock) do
        @pry_commands << [CMD_EVALUATED]
      end
    end
  end
end
