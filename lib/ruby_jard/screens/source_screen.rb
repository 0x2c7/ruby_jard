# frozen_string_literal: true

module RubyJard
  class Screens
    ##
    # Display source code of current stopping line and surrounding lines
    class SourceScreen < RubyJard::Screen
      include ::RubyJard::Span::DSL

      def initialize(*args)
        super
        @frame_file = @session.current_frame&.frame_file
        @frame_line = @session.current_frame&.frame_line

        if !@frame_file.nil? && !@frame_line.nil?
          @path_decorator = RubyJard::Decorators::PathDecorator.new
          @loc_decorator = RubyJard::Decorators::LocDecorator.new
          @source_decorator = RubyJard::Decorators::SourceDecorator.new(@frame_file, @frame_line, @layout.height)
        end

        @selected = 0
      end

      def title
        return 'Source' if @frame_file.nil? || @frame_line.nil?

        _, path_label = @path_decorator.decorate(@frame_file, @frame_line)
        ['Source', path_label]
      end

      def build
        return 'Source' if @frame_file.nil? || @frame_line.nil?

        # TODO: screen now supports window.
        codes = @source_decorator.codes
        @rows = codes.map.with_index do |loc, index|
          lineno = @source_decorator.window_start + index
          Row.new(
            Column.new(
              span_mark(lineno),
              span_lineno(lineno)
            ),
            Column.new(
              *loc_spans(loc),
              word_wrap: Column::WORD_WRAP_BREAK_WORD
            ),
            line_limit: 3
          )
        end
      end

      private

      def span_mark(lineno)
        if @frame_line == lineno
          text_selected('⮕ ')
        else
          text_selected('  ')
        end
      end

      def span_lineno(lineno)
        padded_lineno = lineno.to_s.rjust(@source_decorator.window_end.to_s.length)
        if @frame_line == lineno
          text_selected(padded_lineno)
        else
          text_dim(padded_lineno)
        end
      end

      def loc_spans(loc)
        return [] if @frame_file.nil?

        @loc_decorator.decorate(loc, @frame_file)
      end
    end
  end
end

RubyJard::Screens.add_screen('source', RubyJard::Screens::SourceScreen)
