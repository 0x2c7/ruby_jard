# frozen_string_literal: true

module RubyJard
  module Screens
    class MenuScreen < RubyJard::Screen
      def draw
        @output.print TTY::Cursor.move_to(@row, @col)
        frame = TTY::Box.frame(
          **default_frame_styles.merge(
            top: @row, left: @col, width: @layout.width, height: @layout.height,
            border: {
              left: false,
              top: false,
              right: false,
              bottom: false
            },
            style: {
              fg: :dim,
              bg: :white
            }
          )
        )

        @output.print frame
      end
    end
  end
end

RubyJard::Screens.add_screen(:menu, RubyJard::Screens::MenuScreen)
