# frozen_string_literal: true

require 'io/console'
require 'English'

module RubyJard
  # Wrapper for utilities to control screen
  class Console
    class << self
      def start_alternative_terminal(output)
        return unless output.tty?

        output.print tput('smcup')
      end

      def stop_alternative_terminal(output)
        return unless output.tty?

        output.print tput('rmcup')
      end

      def move_to(output, x, y)
        return unless output.tty?

        output.goto(y, x)
      end

      def screen_size(output)
        return [0, 0] unless output.tty?

        height, width = output.winsize
        [width, height]
      end

      def clear_screen(output)
        return unless output.tty?

        output.print tput('clear')
      end

      def clear_screen_to_end(output)
        return unless output.tty?

        output.print tput('ed')
      end

      def hide_cursor(output)
        return unless output.tty?

        output.print tput('civis')
      end

      def show_cursor(output)
        return unless output.tty?

        output.print tput('cnorm')
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
