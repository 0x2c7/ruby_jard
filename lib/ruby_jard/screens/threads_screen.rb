# frozen_string_literal: true

module RubyJard
  module Screens
    class ThreadsScreen < RubyJard::Screen
      def draw
        @output.print TTY::Cursor.move_to(@row, @col)
        frame = TTY::Box.frame(
          default_frame_styles.merge(
            top: @row, left: @col, width: @layout.width, height: @layout.height,
            title: {
              top_left: ' Threads '
            }
          )
        )

        @output.print frame
      end
    end
  end
end

RubyJard::Screens.add_screen(:threads, RubyJard::Screens::ThreadsScreen)
