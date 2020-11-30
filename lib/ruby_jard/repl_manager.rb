# frozen_string_literal: true

require 'ruby_jard/pager'
require 'ruby_jard/pry_proxy'

module RubyJard
  ##
  # Manage the dance between REPL components
  class ReplManager
    OUTPUT_TICK = 1.to_f / 60 # 60hz

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
      set_console_raw!

      @interceptor.start
      unless @interceptor.interceptable?
        @console.output.puts '*Warning*: One of Jard\'s depedencies (PTY or Readline) is not available or '\
          'patched by another gem. Key bindings are disabled. There may be other side effects.'
      end

      @pry_proxy = create_pry_proxy
      @pry_proxy.start(current_binding)
    ensure
      @state.exiting!
      @interceptor.stop
      @pry_proxy.stop
      set_console_cooked!
    end

    private

    def create_pry_proxy
      PryProxy.new(
        original_input: @interceptor.original_input,
        original_output: @interceptor.original_output,
        redirected_input: @interceptor.redirected_input,
        redirected_output: @interceptor.redirected_output,
        state_hooks: {
          after_read: proc {
            set_console_cooked!
            @state.processing!
            # Sleep 2 ticks, wait for pry to print out all existing output in the queue
            sleep OUTPUT_TICK * 2
          },
          after_handle_line: proc {
            set_console_raw!
            @state.ready!
            dispatch_resize! if @resizing && !@resizing_dispatched
          },
          before_pager: proc {
            @state.processing!
            @state.set_pager!
            set_console_cooked!
          },
          after_pager: proc {
            @state.ready!
            @state.clear_pager!
            set_console_raw!
          }
        }
      )
    end

    def start_resizing
      return if @resizing == true

      @resizing = true
      @resizing_output_mark = @console.stdout_storage.length
      @resizing_dispatched = false
      unless @state.processing?
        @resizing_readline_buffer = @pry_proxy&.line_buffer
        dispatch_resize!
      end
    end

    def dispatch_resize!
      @resizing_dispatched = true
      if @interceptor.interceptable?
        @interceptor.dispatch_command('list')
      else
        RubyJard::ControlFlow.dispatch(:list)
      end
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
      @resizing_dispatched = false
      @resizing = false
    end

    def set_console_cooked!
      return unless @interceptor.interceptable?

      @console.enable_echo!
      @console.cooked!
    end

    def set_console_raw!
      return unless @interceptor.interceptable?

      @console.disable_echo!
      @console.raw!
    end
  end
end
