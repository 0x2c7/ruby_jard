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
    PTY_OUTPUT_TIMEOUT = 1.to_f / 60 # 60hz

    def initialize(console:, key_bindings: nil)
      @console = console
      @state = RubyJard::ReplState.new
      @interceptor = RubyJard::ReplInterceptor.new(@state, @console, key_bindings)

      Signal.trap('SIGWINCH') { start_resizing }
    end

    def repl(current_binding)
      finish_resizing

      @state.ready!
      @state.clear_pager!
      @console.disable_echo!
      @console.raw!
      @interceptor.start

      pry_repl(current_binding)
    ensure
      @state.exiting!
      sleep PTY_OUTPUT_TIMEOUT until @state.exited?
      @console.enable_echo!
      @console.cooked!
      @interceptor.stop
    end

    private

    def pry_repl(current_binding)
      pry_instance.repl(current_binding)
    end

    def pry_instance
      PryProxy.new(
        original_input: @interceptor.original_input,
        original_output: @interceptor.original_output,
        redirected_input: @interceptor.redirected_input,
        redirected_output: @interceptor.redirected_output,
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
            @state.processing!
            @state.set_pager!
            @console.cooked!
          },
          after_pager: proc {
            @state.ready!
            @state.clear_pager!
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
      @interceptor.dispatch_command('list')
    end

    # Flush previous output in the storage higher than a mark, restore pending input if capable
    def finish_resizing
      return if @resizing_output_mark.nil? || @resizing != true

      ((@resizing_output_mark + 1)..@console.stdout_storage.length).each do |line|
        next if @console.stdout_storage[line - 1].nil?

        @console.stdout_storage[line - 1].each do |s|
          @interceptor.feed_output(s)
        end
      end
      unless @resizing_readline_buffer.nil?
        @interceptor.feed_input(@resizing_readline_buffer)
      end
      @resizing_readline_buffer = nil
      @resizing_output_mark = nil
      @resizing = false
    end
  end
end
