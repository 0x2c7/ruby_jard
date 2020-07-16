# frozen_string_literal: true

module RubyJard
  module Screens
    class SourceScreen < RubyJard::Screen
      def title
        return 'Source' if RubyJard.current_session.frame.nil?

        decorated_path = path_decorator(current_file, current_line)
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

        @data_window ||= source_decorator.codes
      end

      def span_mark(_loc, index)
        lineno = source_lineno(index)
        [
          current_line == lineno ? '→' : ' ',
          [:bright_yellow, current_line == lineno ? :bold : nil]
        ]
      end

      def span_lineno(_loc, index)
        lineno = source_lineno(index)
        [
          lineno.to_s,
          current_line == lineno ? [:bold, :bright_yellow] : [:dim, :white]
        ]
      end

      def span_code(loc, index)
        lineno = source_lineno(index)
        [loc_decorator(loc).spans, current_line == lineno ? [:brighter] : [:dim]]
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

      def path_decorator(path, lineno)
        @path_decorator ||= RubyJard::Decorators::PathDecorator.new(path, lineno)
      end

      def source_decorator
        @source_decorator ||= RubyJard::Decorators::SourceDecorator.new(current_file, current_line, data_size)
      end

      def loc_decorator(loc)
        RubyJard::Decorators::LocDecorator.new(loc)
      end

      def source_lineno(index)
        source_decorator.window_start + index
      end
    end
  end
end

RubyJard::Screens.add_screen(:source, RubyJard::Screens::SourceScreen)
