# frozen_string_literal: true

module RubyJard
  module Screens
    class VariablesScreen < RubyJard::Screen
      def draw
        @output.print TTY::Box.frame(
          default_frame_styles.merge(
            top: @row, left: @col, width: @layout.width, height: @layout.height
          )
        )

        @output.print TTY::Cursor.move_to(@col + 2, @row)
        @output.print decorate_text
          .with_highlight(true)
          .text(' Variables ', :bright_yellow)
          .content
      end
    end
  end
end

RubyJard::Screens.add_screen(:variables, RubyJard::Screens::VariablesScreen)
