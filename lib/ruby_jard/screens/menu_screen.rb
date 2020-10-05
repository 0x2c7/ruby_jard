# frozen_string_literal: true

module RubyJard
  class Screens
    ##
    # Display key binding guidelines and shortcuts.
    class MenuScreen < RubyJard::Screen
      include ::RubyJard::Span::DSL

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
        @rows = [
          Row.new(
            Column.new(
              *[
                left_spans,
                align(left_spans, right_spans),
                right_spans
              ].flatten,
              word_wrap: RubyJard::Column::WORD_WRAP_BREAK_WORD
            )
          )
        ]
      end

      private

      def generate_left_spans
        filter_mode_span = text_special("Filter (F2): #{@filter.to_s.gsub(/_/, ' ').capitalize}")
        filter_details =
          @filter_included.map { |f| "+#{f}" } +
          @filter_excluded.map { |f| "-#{f}" }
        if filter_details.empty?
          [filter_mode_span]
        else
          filter_exceprt = filter_details.first(3).join(' ')
          filter_more = filter_details.length > 3 ? " (#{filter_details.length - 3} more...)" : nil
          filter_details_span = text_primary(" #{filter_exceprt}#{filter_more}")
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
          text_primary("   #{menu_item}")
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
