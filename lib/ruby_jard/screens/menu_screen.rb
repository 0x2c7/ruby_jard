# frozen_string_literal: true

module RubyJard
  class Screens
    ##
    # Display key binding guidelines and shortcuts.
    class MenuScreen < RubyJard::Screen
      def initialize(*args)
        super(*args)
        @filter = RubyJard.config.filter
        @filter_included = RubyJard.config.filter_included
        @filter_excluded = RubyJard.config.filter_excluded
        @selected = 0
      end

      def build
        left_spans = generate_left_spans
        right_spans = generate_right_spans
        @rows = [RubyJard::Row.new(
          line_limit: 1,
          columns: [
            RubyJard::Column.new(
              word_wrap: RubyJard::Column::WORD_WRAP_BREAK_WORD,
              spans: [
                left_spans,
                align(left_spans, right_spans),
                right_spans
              ].flatten
            )
          ]
        )]
      end

      private

      def generate_left_spans
        filter_mode_span = RubyJard::Span.new(
          content: "Filter (F2): #{@filter.to_s.gsub(/_/, ' ').capitalize}",
          styles: :text_special
        )
        filter_details =
          @filter_included.map { |f| "+#{f}" } +
          @filter_excluded.map { |f| "-#{f}" }
        if filter_details.empty?
          [filter_mode_span]
        else
          filter_exceprt = filter_details.first(3).join(' ')
          filter_more = filter_details.length > 3 ? " (#{filter_details.length - 3} more...)" : nil
          filter_details_span = RubyJard::Span.new(
            content: "#{filter_exceprt}#{filter_more}",
            styles: :text_secondary,
            margin_left: 1
          )
          [
            filter_mode_span,
            filter_details_span
          ]
        end
      end

      def generate_right_spans
        [
          'Step (F7)',
          'Step Out (Shift+F7)',
          'Next (F8)',
          'Continue (F9)'
        ].map do |menu_item|
          RubyJard::Span.new(
            content: menu_item,
            margin_left: 3,
            styles: :text_secondary
          )
        end
      end

      def align(left_spans, right_spans)
        alignment =
          @layout.width -
          right_spans.map(&:content_length).sum -
          left_spans.map(&:content_length).sum
        RubyJard::Span.new(
          content: ' ' * (alignment < 0 ? 0 : alignment),
          styles: :background
        )
      end
    end
  end
end

RubyJard::Screens.add_screen('menu', RubyJard::Screens::MenuScreen)
