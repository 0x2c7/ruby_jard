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
  #                             +------- Intercept key binding
  #                             v                ^
  #   Resize signal +---> Escape sequence        |
  #                             +                |
  # +-----------------+         v        +-------+-------+
  # |    Thread 1     |        PIPE <----+ Listen Thread <--+ STDIN
  # +-----------------+         +        +---------------+
  #                             |
  # +-----------------+         v
  # | Stopping thread +--> Pry REPL loop +----> Capture and dispatch command
  # +-----------------+         +
  #                             |
  # +-----------------+         v        +---------------+
  # |    Thread 2     |        PTY  +----> Output Thread +--> STDOUT
  # +-----------------+         +        +---------------+
  #                             |
  #                             |
  #                             +-------> Discard escape sequence
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

    # Escape sequence used to mark command from key binding
    COMMAND_ESCAPE_SEQUENCE = '\e]711;Command~'
    INTERNAL_KEY_BINDINGS = {
      RubyJard::Keys::CTRL_C => (KEY_BINDING_INTERRUPT = :interrupt)
    }.freeze

    KEY_READ_TIMEOUT = 0.2           # 200ms
    PTY_OUTPUT_TIMEOUT = 1.to_f / 60 # 60hz

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

    def initialize(console:, key_bindings: nil)
      @console = console
      @state = ReplState.new

      @pry_input_pipe_read, @pry_input_pipe_write = IO.pipe
      @pry_output_pty_read, @pry_output_pty_write = PTY.open

      @key_bindings = key_bindings || RubyJard::KeyBindings.new
      INTERNAL_KEY_BINDINGS.each do |sequence, action|
        @key_bindings.push(sequence, action)
      end

      @pry_pty_output_thread = Thread.new { pry_pty_output }
      @pry_pty_output_thread.abort_on_exception = true
      @pry_pty_output_thread.report_on_exception = false
      @pry_pty_output_thread.name = '<<Jard: Pty Output Thread>>'

      Signal.trap('SIGWINCH') { start_resizing }
    end

    def repl(current_binding)
      reopen_streams
      finish_resizing

      @state.ready!
      @openning_pager = false
      @console.disable_echo!
      @console.raw!
      # Internally, Pry sneakily updates Readline to global output config
      # when STDOUT is piping regardless of what I pass into Pry instance.
      Pry.config.output = @pry_output_pty_write
      Readline.input = @pry_input_pipe_read
      Readline.output = @pry_output_pty_write

      @main_thread = Thread.current

      @key_listen_thread = Thread.new { listen_key_press }
      @key_listen_thread.abort_on_exception = true
      @key_listen_thread.report_on_exception = false
      @key_listen_thread.name = '<<Jard: Repl key listen >>'

      pry_repl(current_binding)
    ensure
      @state.exiting!
      sleep PTY_OUTPUT_TIMEOUT until @state.exited?
      @console.enable_echo!
      @console.cooked!
      Readline.input = @console.input
      Readline.output = @console.output
      Pry.config.output = @console.output
      @key_listen_thread&.exit if @key_listen_thread&.alive?
    end

    private

    def reopen_streams
      if @pry_input_pipe_read.closed? || @pry_input_pipe_write.closed?
        @pry_input_pipe_read, @pry_input_pipe_write = IO.pipe
      end

      if @pry_output_pty_read.closed? || @pry_output_pty_write.closed?
        @pry_output_pty_read, @pry_output_pty_write = PTY.open
      end
    end

    def pry_repl(current_binding)
      pry_instance.repl(current_binding)
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
    rescue StandardError
      # This thread shoud never die, or the user may be freezed, and cannot type anything
      sleep 0.5
      retry
    end

    def listen_key_press
      loop do
        break if @pry_input_pipe_write.closed?
        break if @state.exiting? || @state.exited?

        if @state.processing? && @openning_pager
          # Discard all keys unfortunately
          sleep PTY_OUTPUT_TIMEOUT
        else
          key = @key_bindings.match { @console.getch(KEY_READ_TIMEOUT) }
          if key.is_a?(RubyJard::KeyBinding)
            handle_key_binding(key)
          elsif !key.empty?
            @pry_input_pipe_write.write(key)
          end
        end
      end
    rescue IOError
      # Nothing we can do about it, let the program continues
    end

    def handle_key_binding(key_binding)
      case key_binding.action
      when KEY_BINDING_INTERRUPT
        handle_interrupt_command
      else
        @state.check(:ready?) do
          dispatch_command(key_binding.action)
        end
      end
    end

    def handle_interrupt_command
      @state.check(:ready?) do
        @main_thread&.raise Interrupt if @main_thread&.alive?
      end
      loop do
        begin
          sleep PTY_OUTPUT_TIMEOUT
        rescue Interrupt
          # Interrupt spam. Ignore.
        end
        break unless @main_thread&.pending_interrupt?
      end
    end

    def dispatch_command(command)
      @pry_input_pipe_write.write("#{COMMAND_ESCAPE_SEQUENCE}#{command}\n")
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
      pry_instance.instance_variable_set(:@console, @console)
      class << pry_instance
        attr_reader :console

        def _jard_handle_line(line, *args)
          index = line.rindex(RubyJard::ReplProxy::COMMAND_ESCAPE_SEQUENCE)
          if !index.nil?
            command = line[(index + RubyJard::ReplProxy::COMMAND_ESCAPE_SEQUENCE.length)..-1]
            _original_handle_line(command, *args)
          else
            _original_handle_line(line, *args)
          end
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
      # TODO: Create a dedicated registry to store Jard commands, and merge with Pry default commands
      # This approach allows Jard and Binding.pry co-exist even after Jard already started
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
        @console.cooked!
        @state.processing!
        # Sleep 2 ticks, wait for pry to print out all existing output in the queue
        sleep PTY_OUTPUT_TIMEOUT * 2
      end
      hooks.add_hook(:after_handle_line, :jard_proxy_release_lock) do
        @console.raw!
        @state.ready!
      end
      hooks.add_hook(:before_pager, :jard_proxy_before_pager) do
        @openning_pager = true

        @state.processing!
        @console.cooked!
      end
      hooks.add_hook(:after_pager, :jard_proxy_after_pager) do
        @openning_pager = false
        @state.ready!
        @console.raw!
      end
    end

    def start_resizing
      return if @resizing == true

      @resizing = true
      @resizing_output_mark = @console.stdout_storage.length
      @resizing_readline_buffer = Readline.line_buffer unless @state.processing?
      dispatch_command('list')
    end

    # Flush previous output in the storage higher than a mark, restore pending input if capable
    def finish_resizing
      return if @resizing_output_mark.nil? || @resizing != true

      ((@resizing_output_mark + 1)..@console.stdout_storage.length).each do |line|
        next if @console.stdout_storage[line - 1].nil?

        @console.stdout_storage[line - 1].each do |s|
          @pry_output_pty_write.write(s)
        end
      end
      unless @resizing_readline_buffer.nil?
        @pry_input_pipe_write.write(@resizing_readline_buffer)
      end
      @resizing_readline_buffer = nil
      @resizing_output_mark = nil
      @resizing = false
    end

    def write_output(content)
      return if content.include?(COMMAND_ESCAPE_SEQUENCE)

      @console.write content.force_encoding('UTF-8')
    end
  end
end
