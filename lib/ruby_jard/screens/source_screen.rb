# frozen_string_literal: true

module RubyJard
  module Screens
    class SourceScreen < RubyJard::Screen
      def draw
        frame = TTY::Box.frame(
          **default_frame_styles.merge(
            top: @row, left: @col, width: @layout.width, height: @layout.height,
            title: {
              top_left: " Source ",
              top_right: file_path
            }
          )
        )

        @output.print frame

        @output.print TTY::Cursor.move_to(@col, @row + 1)
        @output.print codes
      end

      private

      def codes
        return '' if RubyJard.current_session.frame.nil?

        Pry::Code
          .from_file(RubyJard.current_session.frame.file)
          .around(RubyJard.current_session.frame.line, (@layout.height - 1) / 2 - 1)
          .with_line_numbers
          .with_marker(RubyJard.current_session.frame.line)
          .highlighted
      end

      def file_path
        return '' if RubyJard.current_session.frame.nil?

        "#{RubyJard.current_session.frame.file}:#{RubyJard.current_session.frame.line}"
      end
    end
  end
end

RubyJard::Screens.add_screen(:source, RubyJard::Screens::SourceScreen)
