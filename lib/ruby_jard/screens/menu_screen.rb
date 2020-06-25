# frozen_string_literal: true

module RubyJard
  module Screens
    class MenuScreen < RubyJard::Screen
      def draw
        @output.print TTY::Cursor.move_to(@col, @row)
        frame = TTY::Box.frame(
          **default_frame_styles.merge(
            top: @row, left: @col, width: @layout.width, height: @layout.height,
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
        )
        @output.print frame

        margin = 0
        left_menu = generate_left_menu
        left_menu.each do |item|
          @output.print TTY::Cursor.move_to(@col + 1 + margin, @row + 1)
          @output.print item.content
          margin += item.length + 3
        end

        margin = 0
        right_menu = generate_right_menu
        right_menu.reverse.each do |item|
          @output.print TTY::Cursor.move_to(@col + @layout.width - margin - item.length - 1, @row + 1)
          @output.print item.content
          margin += item.length + 3
        end
      end

      private

      def generate_left_menu
        [
          decorate_text.with_highlight(true).text('Debug console (F5)', :bright_yellow),
          decorate_text.text('Program output (F6)', :white)
        ]
      end

      def generate_right_menu
        [
          decorate_text.text('Step (F7)', :white),
          decorate_text.text('Next (F8)', :white),
          decorate_text.text('Step out (Shift+F8)', :white),
          decorate_text.text('Continue (F9)', :white)
        ]
      end
    end
  end
end

RubyJard::Screens.add_screen(:menu, RubyJard::Screens::MenuScreen)
