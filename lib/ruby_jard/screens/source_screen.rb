# frozen_string_literal: true

module RubyJard
  module Screens
    class SourceScreen < RubyJard::Screen
      def draw
        frame = TTY::Box.frame(
          **default_frame_styles.merge(
            top: @row, left: @col, width: @layout.width, height: @layout.height,
            title: {
              top_left: ' Source ',
              top_right: file_path
            }
          )
        )

        @output.print frame

        decorate_codes.each_with_index do |decorated_loc, index|
          @output.print TTY::Cursor.move_to(@col + 1, @row + 1 + index)
          @output.print decorated_loc.content
        end
      end

      private

      def data_size
        @layout.height - 1
      end

      def decorate_codes
        return [] if RubyJard.current_session.frame.nil?

        decorated_source = decorate_source(current_file, current_line, data_size)

        lineno_padding = decorated_source.window_end.to_s.length

        decorated_source.codes.map.with_index do |loc, index|
          lineno = decorated_source.window_start + index
          lineno_color = current_line == lineno ? :green : :white
          mark = current_line == lineno ? '→' : ' '

          decorated_loc = decorate_loc(loc)

          decorate_text
            .with_highlight(current_line == lineno)
            .text(mark)
            .text(' ')
            .text(lineno.to_s.ljust(lineno_padding), lineno_color)
            .text(' ')
            .text(decorated_loc.loc)
        end
      end

      def file_path
        return '' if RubyJard.current_session.frame.nil?

        "#{current_file}:#{current_line}"
      end

      def current_file
        RubyJard.current_session.frame.file
      end

      def current_line
        RubyJard.current_session.frame.line
      end
    end
  end
end

RubyJard::Screens.add_screen(:source, RubyJard::Screens::SourceScreen)
