# frozen_string_literal: true

require 'io/console'

module RubyJard
  # Wrapper for utilities to control screen
  class Console
    class << self
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

        output.clear_screen
      end
    end
  end
end
