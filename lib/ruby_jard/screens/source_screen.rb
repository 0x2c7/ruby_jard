# frozen_string_literal: true

module RubyJard
  module Screens
    class SourceScreen < RubyJard::Screen
      def title
        return 'Source' if RubyJard.current_session.frame.nil?

        decorated_path = decorate_path(current_file, current_line)
        if decorated_path.gem?
          "Source (#{decorated_path.gem} - #{decorated_path.path}:#{decorated_path.lineno})"
        else
          "Source (#{decorated_path.path}:#{decorated_path.lineno})"
        end
      end

      def data_size
        @height
      end

      def data_window
        return [] if RubyJard.current_session.frame.nil?

        @data_window ||= decorated_source.codes
      end

      def decorated_source
        @decorated_source ||= decorate_source(current_file, current_line, data_size)
      end

      def draw
        adjust_screen_size_to_borders

        calculate
        # TODO: move this out to ScreenManager
        drawer = RubyJard::ScreenDrawer.new(
          output: @output,
          screen: self,
          x: @col,
          y: @row
        )
        drawer.draw
      end

      def span_mark(_loc, index)
        lineno = decorated_source.window_start + index
        [
          current_line == lineno ? '→' : ' ',
          [:bright_yellow, current_line == lineno ? :bold : nil]
        ]
      end

      def span_lineno(_loc, index)
        lineno = decorated_source.window_start + index
        [
          lineno.to_s,
          current_line == lineno ? [:bold, :bright_yellow] : [:white]
        ]
      end

      def span_code(loc, index)
        lineno = decorated_source.window_start + index
        [decorate_loc(loc).spans, current_line == lineno ? :bold : nil]
      end

      private

      def current_binding
        RubyJard.current_session.frame._binding
      end

      def current_frame_scope
        RubyJard.current_session.backtrace[RubyJard.current_session.frame.pos][1]
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
