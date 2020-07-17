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

      def hard_clear_screen(output)
        return unless output.tty?

        output.print tput('clear')
      end

      def clear_screen(output)
        return unless output.tty?

        output.clear_screen
      end

      def hide_cursor(output)
        return unless output.tty?

        output.print tput('civis')
      end

      def show_cursor(output)
        return unless output.tty?

        output.print tput('cvvis')
      end

      def cooked!(output)
        return unless output.tty?

        output.cooked!
      end

      def echo!(output)
        return unless output.tty?

        output.echo = true
      end

      def tput(*args)
        # TODO: Should implement multiple fallbacks here to support different platforms

        command = "tput #{args.join(' ')}"
        output = `#{command}`
        if $CHILD_STATUS.success?
          output
        else
          raise Ruby::Error, "Fail to call `#{command}`: #{$CHILD_STATUS}"
        end
      rescue StandardError => e
        raise Ruby::Error, "Fail to call `#{command}`. Error: #{e}"
      end
    end
  end
end
