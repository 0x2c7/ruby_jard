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
    # Pager using GNU Less
    class LessPager < Pry::Pager::NullPager
      def initialize(pry_instance, force_open: false, pager_start_at_the_end: false, prompt: nil)
        super(pry_instance.output)
        @pry_instance = pry_instance
        @buffer = ''

        @pager_start_at_the_end = pager_start_at_the_end
        @prompt = prompt

        @tracker = Pry::Pager::PageTracker.new(height, width)
        @pager = force_open ? open_pager : nil
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

          prompt = @pry_instance.prompt.wait_proc.call
          # TODO: should show this tip even pager not invoked, when the size exceed a certain height
          @out.puts "#{prompt}Tips: You can use `list` command to show back debugger screens"
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
          out: @pry_instance.output, err: @pry_instance.output
        )
      end

      def write_into_pager(str)
        return unless invoked_pager?

        @pager.write str.encode('UTF-8', undef: :replace)
      end
    end
  end
end
