# frozen_string_literal: true

module RubyJard
  module Screens
    ##
    # Display source code of current stopping line and surrounding lines
    class SourceScreen < RubyJard::Screen
      def title
        return 'Source' if @session.current_frame.nil?

        decorated_path = path_decorator(@session.current_frame.frame_file, @session.current_frame.frame_line)
        if decorated_path.gem?
          ['Source', "#{decorated_path.gem} - #{decorated_path.path}:#{decorated_path.lineno}"]
        else
          ['Source', "#{decorated_path.path}:#{decorated_path.lineno}"]
        end
      end

      def build
        return if @session.current_frame.nil?

        if @session.current_frame.frame_file == '(eval)'
          # (eval) is hard-coded in Ruby source code for in-code evaluation
          handle_anonymous_evaluation
        else
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
        end
        @selected = 0
      end

      private

      def handle_anonymous_evaluation
        @rows = [
          RubyJard::Row.new(
            line_limit: 3,
            columns: [
              RubyJard::Column.new(
                spans: [
                  RubyJard::Span.new(
                    content: 'This section is anonymous!',
                    styles: :normal_token
                  )
                ]
              )
            ]
          ),
          RubyJard::Row.new(
            line_limit: 3,
            columns: [
              RubyJard::Column.new(
                spans: [
                  RubyJard::Span.new(
                    content: 'Maybe it is dynamically evaluated without file information.',
                    styles: :source_lineno
                  )
                ]
              )
            ]
          )
        ]
      end

      def span_mark(index)
        lineno = source_lineno(index)
        RubyJard::Span.new(
          margin_right: 1,
          content: @session.current_frame.frame_line == lineno ? '➠' : ' ',
          styles: :source_line_mark
        )
      end

      def span_lineno(index)
        lineno = source_lineno(index).to_s.rjust(source_decorator.window_end.to_s.length)
        RubyJard::Span.new(
          content: lineno,
          styles: @session.current_frame.frame_line == lineno ? :source_line_mark : :source_lineno
        )
      end

      def loc_spans(loc)
        spans, _tokens = loc_decorator.decorate(loc, @session.current_frame.frame_file)
        spans
      end

      def path_decorator(path, lineno)
        @path_decorator ||= RubyJard::Decorators::PathDecorator.new(path, lineno)
      end

      def source_decorator
        @source_decorator ||= RubyJard::Decorators::SourceDecorator.new(
          @session.current_frame.frame_file, @session.current_frame.frame_line, @layout.height
        )
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
