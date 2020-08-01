# frozen_string_literal: true

module RubyJard
  module Screens
    ##
    # Display key binding guidelines and shortcuts.
    class MenuScreen < RubyJard::Screen
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
        @selected = 0
      end

      private

      def generate_left_spans
        [
          RubyJard::Span.new(
            content: ' Mode (F2) ',
            styles: :title_highlighted
          ),
          RubyJard::Span.new(
            margin_left: 1,
            content: 'All gems',
            styles: :menu_mode
          ),
          RubyJard::Span.new(
            margin_left: 1,
            content: '|',
            styles: :menu_tips
          ),
          RubyJard::Span.new(
            margin_left: 1,
            content: 'Application only',
            styles: :menu_tips
          )
        ]
      end

      def generate_right_spans
        [
          'Up (F6)',
          'Down (Shift+F6)',
          'Step (F7)',
          'Step Out (Shift+F7)',
          'Next (F8)',
          'Continue (F9)'
        ].map do |menu_item|
          RubyJard::Span.new(
            content: menu_item,
            margin_left: 3,
            styles: :menu_tips
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

RubyJard::Screens.add_screen(:menu, RubyJard::Screens::MenuScreen)
