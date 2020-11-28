# frozen_string_literal: true

require 'pty'
require 'ruby_jard/pager'
require 'ruby_jard/pry_proxy'

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
  class ReplManager
    # Escape sequence used to mark command from key binding
    COMMAND_ESCAPE_SEQUENCE = '\e]711;Command~'
    INTERNAL_KEY_BINDINGS = {
      RubyJard::Keys::CTRL_C => (KEY_BINDING_INTERRUPT = :interrupt)
    }.freeze

    KEY_READ_TIMEOUT = 0.2           # 200ms
    PTY_OUTPUT_TIMEOUT = 1.to_f / 60 # 60hz

    def initialize(console:, key_bindings: nil)
      @console = console
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
    rescue StandardError
      # This thread shoud never die, or the user may be freezed, and cannot type anything
      sleep 0.5
      retry
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
      PryProxy.new(
        original_input: @console.input,
        original_output: @console.output,
        redirected_input: @pry_input_pipe_read,
        redirected_output: @pry_output_pty_write,
        state_hooks: {
          after_read: proc {
            @console.cooked!
            @state.processing!
            # Sleep 2 ticks, wait for pry to print out all existing output in the queue
            sleep PTY_OUTPUT_TIMEOUT * 2
          },
          after_handle_line: proc {
            @console.raw!
            @state.ready!
          },
          before_pager: proc {
            @openning_pager = true

            @state.processing!
            @console.cooked!
          },
          after_pager: proc {
            @openning_pager = false
            @state.ready!
            @console.raw!
          }
        }
      )
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
