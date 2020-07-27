# frozen_string_literal: true

module RubyJard
  module Screens
    class MenuScreen < RubyJard::Screen
      def build
        span_title = RubyJard::Span.new(
          content: ' REPL Console ',
          styles: :title_highlighted
        )
        menu_spans = generate_menu_spans

        alignment =
          @layout.width -
          span_title.content_length -
          menu_spans.map(&:content_length).sum
        span_align = RubyJard::Span.new(
          content: ' ' * (alignment < 0 ? 0 : alignment),
          styles: :background
        )
        @rows = [RubyJard::Row.new(
          line_limit: 1,
          ellipsis: false,
          columns: [
            RubyJard::Column.new(
              spans: [
                span_title,
                span_align,
                menu_spans
              ].flatten
            )
          ]
        )]
        @selected = 0
      end

      private

      def generate_menu_spans
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
            styles: :control_buttons
          )
        end
      end
    end
  end
end

RubyJard::Screens.add_screen(:menu, RubyJard::Screens::MenuScreen)
