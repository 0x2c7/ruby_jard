# frozen_string_literal: true

module RubyJard
  module Screens
    class MenuScreen < RubyJard::Screen
      def draw(output, x, y)
        output.print TTY::Cursor.move_to(x, y)
        frame = generate_frame(x, y)
        output.print frame

        margin = 0
        left_menu = generate_left_menu
        left_menu.each do |text, length|
          output.print TTY::Cursor.move_to(x + 1 + margin, y + 1)
          output.print text
          margin += length + 3
        end

        margin = 0
        right_menu = generate_right_menu
        right_menu.reverse.each do |text, length|
          output.print TTY::Cursor.move_to(x + @width - margin - length - 1, y + 1)
          output.print text
          margin += length + 3
        end
      end

      private

      def generate_frame(x, y)
        TTY::Box.frame(
          top: y, left: x, width: @width, height: @height,
          border: {
            left: false,
            top: :line,
            right: false,
            bottom: false
          },
          style: {
            fg: :white
          }
        )
      end

      def generate_left_menu
        [
          decorate_text('Debug console (F5)', :bright_yellow),
          decorate_text('Program output (F6)', :white)
        ]
      end

      def generate_right_menu
        [
          decorate_text('Step (F7)', :white),
          decorate_text('Next (F8)', :white),
          decorate_text('Step out (Shift+F8)', :white),
          decorate_text('Continue (F9)', :white)
        ]
      end

      def decorate_text(str, *styles)
        [color_decorator.decorate(str, *styles), str.length]
      end

      def color_decorator
        @color_decorator ||= Pastel.new
      end
    end
  end
end

RubyJard::Screens.add_screen(:menu, RubyJard::Screens::MenuScreen)
