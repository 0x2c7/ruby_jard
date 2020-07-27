# frozen_string_literal: true

module RubyJard
  module Screens
    class SourceScreen < RubyJard::Screen
      def title
        return 'Source' if RubyJard.current_session.frame.nil?

        decorated_path = path_decorator(current_file, current_line)
        if decorated_path.gem?
          ['Source', "#{decorated_path.gem} - #{decorated_path.path}:#{decorated_path.lineno}"]
        else
          ['Source', "#{decorated_path.path}:#{decorated_path.lineno}"]
        end
      end

      def build
        return if RubyJard.current_session.frame.nil?

        # TODO: screen now supports window.
        codes = source_decorator.codes
        @rows = codes.map.with_index do |loc, index|
          RubyJard::Row.new(
            line_limit: 3,
            columns: [
              RubyJard::Column.new(
                spans: [
                  span_mark(index),
                  span_lineno(index)
                ]
              ),
              RubyJard::Column.new(
                word_wrap: RubyJard::Column::WORD_WRAP_BREAK_WORD,
                spans: loc_spans(loc)
              )
            ]
          )
        end
        @selected = 0
      end

      def span_mark(index)
        lineno = source_lineno(index)
        RubyJard::Span.new(
          margin_right: 1,
          content: current_line == lineno ? '➠' : ' ',
          styles: :source_line_mark
        )
      end

      def span_lineno(index)
        lineno = source_lineno(index).to_s.rjust(source_decorator.window_end.to_s.length)
        RubyJard::Span.new(
          content: lineno,
          styles: current_line == lineno ? :source_line_mark : :source_lineno
        )
      end

      def loc_spans(loc)
        spans, _tokens = loc_decorator.decorate(loc, current_file)
        spans
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
        @source_decorator ||= RubyJard::Decorators::SourceDecorator.new(current_file, current_line, @layout.height)
      end

      def loc_decorator
        @loc_decorator ||= RubyJard::Decorators::LocDecorator.new
      end

      def source_lineno(index)
        source_decorator.window_start + index
      end
    end
  end
end

RubyJard::Screens.add_screen(:source, RubyJard::Screens::SourceScreen)
