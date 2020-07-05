# frozen_string_literal: true

module RubyJard
  module Screens
    class MenuScreen < RubyJard::Screen
      def draw(output, x, y)
        output.print TTY::Cursor.move_to(x, y)

        margin = 0
        left_menu = generate_left_menu
        left_menu.each do |text, length|
          output.print TTY::Cursor.move_to(x + 1 + margin, y)
          output.print text
          margin += length + 3
        end

        margin = 0
        right_menu = generate_right_menu
        right_menu.reverse.each do |text, length|
          output.print TTY::Cursor.move_to(x + @width - margin - length - 1, y)
          output.print text
          margin += length + 3
        end
      end

      private

      def generate_left_menu
        [
          decorate_text('Debug console (F5)', :bright_yellow)
        ]
      end

      def generate_right_menu
        [
          decorate_text('Step (F7)', :white),
          decorate_text('Next (F8)', :white),
          decorate_text('Up (F6)', :white),
          decorate_text('Down (Shift+F6)', :white),
          decorate_text('Continue (F9)', :white)
        ]
      end

      def decorate_text(str, *styles)
        [color_decorator.decorate(str, *styles), str.length]
      end

      def color_decorator
        @color_decorator ||= RubyJard::Decorators::ColorDecorator.new
      end
    end
  end
end

RubyJard::Screens.add_screen(:menu, RubyJard::Screens::MenuScreen)
