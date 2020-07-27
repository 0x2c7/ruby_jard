# frozen_string_literal: true

require 'English'

module RubyJard
  # Wrapper for utilities to control screen
  class Console
    class << self
      def start_alternative_terminal(output)
        return unless output.tty?

        output.print tput('smcup')
      rescue RubyJard::Error
        # If tput not found or rmcup not supported, the system still work like normal
      end

      def stop_alternative_terminal(output)
        return unless output.tty?

        output.print tput('rmcup')
      rescue RubyJard::Error
        # If tput not found or rmcup not supported, the system still work like normal
      end

      def move_to(output, x, y)
        return unless output.tty?

        output.print format("\e[%<row>d;%<col>dH", row: y, col: x)
      end

      def screen_size(output)
        return [0, 0] unless output.tty?

        begin
          height = tput('lines').strip.to_i
          width = tput('cols').strip.to_i
          [width, height]
        rescue RubyJard::Error
          require 'io/console'
          height, width = output.winsize
          [width, height]
        end
      end

      def clear_screen(output)
        return unless output.tty?

        output.print "\e[3J"
      end

      def clear_screen_to_end(output)
        return unless output.tty?

        output.print "\e[0J"
      end

      def hide_cursor(output)
        return unless output.tty?

        output.print tput('civis')
      rescue RubyJard::Error
        # If tput not found or rmcup not supported, the system still work like normal
      end

      def show_cursor(output)
        return unless output.tty?

        output.print tput('cnorm')
      rescue RubyJard::Error
        # If tput not found or rmcup not supported, the system still work like normal
      end

      def cooked!(output)
        return unless output.tty?

        output.cooked!
      end

      def echo!(output)
        return unless output.tty?

        output.echo = true
      end

      def cached_tput
        @cached_tput ||= {}
      end

      def tput(*args)
        command = "tput #{args.join(' ')}"
        return cached_tput[command] unless cached_tput[command].nil?

        output = `#{command}`
        if $CHILD_STATUS.success?
          cached_tput[command] = output
        else
          raise RubyJard::Error, "Fail to call `#{command}`: #{$CHILD_STATUS}"
        end
      rescue StandardError => e
        raise RubyJard::Error, "Fail to call `#{command}`. Error: #{e}"
      end
    end
  end
end
