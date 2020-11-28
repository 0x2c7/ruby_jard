# frozen_string_literal: true

module RubyJard
  class ReplInterceptor
    INTERNAL_KEY_BINDINGS = {
      RubyJard::Keys::CTRL_C => (KEY_BINDING_INTERRUPT = :interrupt)
    }.freeze

    KEY_READ_TIMEOUT = 0.2           # 200ms
    PTY_OUTPUT_TIMEOUT = 1.to_f / 60 # 60hz

    def initialize(state, console, key_bindings)
      @state = state
      @console = console

      @key_bindings = key_bindings || RubyJard::KeyBindings.new
      INTERNAL_KEY_BINDINGS.each do |sequence, action|
        @key_bindings.push(sequence, action)
      end

      reopen_streams
      start_output_bridge
    end

    def start
      reopen_streams
      start_key_listen_thread
    end

    def stop
      @key_listen_thread&.exit if @key_listen_thread&.alive?
      if interceptable?
        sleep PTY_OUTPUT_TIMEOUT until @state.exited?
      else
        @state.exited!
      end
    end

    def dispatch_command(command)
      @input_writer.write("#{RubyJard::ReplManager::COMMAND_ESCAPE_SEQUENCE}#{command}\n")
    end

    def feed_output(content)
      @output_writer.write(content)
    end

    def feed_input(content)
      @input_writer.write(content)
    rescue IOError
      # Nothing to do. Discard the content
    end

    def original_input
      @console.input
    end

    def original_output
      @console.output
    end

    def redirected_input
      @input_reader
    end

    def redirected_output
      @output_writer
    end

    def interceptable?
      return false if defined?(Reline) && Readline == Reline
      return false if RubyJard::Reflection.instance.call_method(::Readline, :input=).source_location != nil
      return false if RubyJard::Reflection.instance.call_method(::Readline, :output=).source_location != nil

      true
    end

    private

    def reopen_streams
      unless interceptable?
        @input_reader = @console.input
        @input_writer = @console.input
        @output_reader = @console.output
        @output_writer = @console.output
        return
      end

      if !defined?(@input_reader) || @input_reader.closed? || @input_writer.closed?
        @input_reader, @input_writer = IO.pipe
      end

      if !defined?(@output_reader) || @output_reader.closed? || @output_writer.closed?
        @output_reader, @output_writer = PTY.open
      end
    end

    def start_output_bridge
      return unless interceptable?

      @output_bridge_thread = Thread.new { output_bridge }
      @output_bridge_thread.abort_on_exception = true
      @output_bridge_thread.report_on_exception = false
      @output_bridge_thread.name = '<<Jard: Pty Output Thread>>'
    end

    def start_key_listen_thread
      return unless interceptable?

      @main_thread = Thread.current
      @key_listen_thread = Thread.new { listen_key_press }
      @key_listen_thread.abort_on_exception = true
      @key_listen_thread.report_on_exception = false
      @key_listen_thread.name = '<<Jard: Repl key listen >>'
    end

    def output_bridge
      loop do
        if @state.exiting?
          if @output_reader.ready?
            write_output(@output_reader.read_nonblock(2048))
          else
            @state.exited!
          end
        elsif @state.exited?
          sleep PTY_OUTPUT_TIMEOUT
        else
          content = @output_reader.read_nonblock(2048)
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
        break if @input_writer.closed?
        break if @state.exiting? || @state.exited?

        if @state.processing? && @state.pager?
          # Discard all keys unfortunately
          sleep PTY_OUTPUT_TIMEOUT
        else
          key = @key_bindings.match { @console.getch(KEY_READ_TIMEOUT) }
          if key.is_a?(RubyJard::KeyBinding)
            handle_key_binding(key)
          elsif !key.empty?
            @input_writer.write(key)
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

    def write_output(content)
      return if content.include?(RubyJard::ReplManager::COMMAND_ESCAPE_SEQUENCE)

      @console.write content.force_encoding('UTF-8')
    end
  end
end
