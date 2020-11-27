# frozen_string_literal: true

module RubyJard
  ##
  # Override Pry's pager system. Again, Pry doesn't support customizing pager. So...
  class Pager
    def initialize(pry_instance)
      @pry_instance = pry_instance
    end

    def page(text)
      open do |pager|
        pager << text
      end
    end

    def open(options = {})
      pager = LessPager.new(@pry_instance, **options)
      yield pager
    rescue Pry::Pager::StopPaging
      # Ignore
    ensure
      pager.close
    end

    private

    def enabled?
      !!@enabled
    end

    ##
    # Pager tracker in Pry does not expose enough
    class JardPageTracker < Pry::Pager::PageTracker
      attr_reader :row, :col
    end

    ##
    # Pager using GNU Less
    class LessPager < Pry::Pager::NullPager
      def initialize(pry_instance, force_open: false, pager_start_at_the_end: false, prompt: nil)
        @pry_instance = pry_instance
        @console = RubyJard::Session.instance.screen_manager.console
        @buffer = ''

        @pager_start_at_the_end = pager_start_at_the_end
        @prompt = prompt

        # There are two cases:
        # - If the real pager (less) is triggered, it works on a real tty (fetched
        # from /dev/tty), in which, the same as RubyJard::Console.output
        # - Otherwise, it writes directly into pry's REPL output.
        # That's why there should be two output here
        @tty_output = @console.redirected? ? @console.output : @pry_instance.output
        @window_width, @window_height = @console.screen_size
        @tracker = JardPageTracker.new(@window_height, @window_width)
        @pager = force_open ? open_pager : nil
        super(@pry_instance.output)
      end

      def write(str)
        if invoked_pager?
          write_into_pager str
        else
          @tracker.record str
          @buffer += str
          if @tracker.page?
            @pager = open_pager
            write_into_pager(@buffer)
          end
        end
      rescue Errno::EPIPE
        raise Pry::Pager::StopPaging
      end

      def close
        if invoked_pager?
          @pager.close
          @pry_instance.exec_hook :after_pager, self

          list_prompt
        elsif @tracker.row > @window_height / 2
          @out.write @buffer

          list_prompt
        else
          @out.write @buffer
        end
      end

      def invoked_pager?
        @pager
      end

      def open_pager
        @pry_instance.exec_hook :before_pager, self
        less_command = ['less', '-R', '-X']
        less_command << "--prompt \"#{@prompt}\"" if @prompt
        less_command << '+G' if @pager_start_at_the_end

        IO.popen(
          less_command.join(' '), 'w',
          out: @tty_output, err: @tty_output
        )
      end

      def write_into_pager(str)
        return unless invoked_pager?

        @pager.write str.encode('UTF-8', undef: :replace)
      end

      def list_prompt
        prompt = @pry_instance.prompt.wait_proc.call
        @out.puts "#{prompt}Tips: You can use `list` command to show back debugger screens"
      end
    end
  end
end
