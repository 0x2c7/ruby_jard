# frozen_string_literal: true

module RubyJard
  module Templates
    ##
    # Template for a span. Span is the most basic unit of display. It is just a sequence of characters, styles, and
    # other layout properties.
    class SpanTemplate
      attr_reader :name, :margin_right, :margin_left, :styles, :word_wrap, :priority

      def initialize(
        name,
        margin_left: 0, margin_right: 0,
        styles: [], word_wrap: false, priority: 0
      )
        @name = name
        @margin_left = margin_left
        @margin_right = margin_right
        @styles = styles
        @word_wrap = word_wrap
        @priority = priority
      end
    end
  end
end
