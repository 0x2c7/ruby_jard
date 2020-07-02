# frozen_string_literal: true

module RubyJard
  module Templates
    ##
    # Template for a span. Span is the most basic unit of display. It is just a sequence of characters, styles, and
    # other layout properties.
    class SpanTemplate
      attr_reader :name, :margin_right, :margin_left, :word_wrap, :priority, :ellipsis

      def initialize(
        name,
        margin_left: 0, margin_right: 0,
        ellipsis: false, word_wrap: false, priority: 0
      )
        @name = name
        @margin_left = margin_left
        @margin_right = margin_right
        @priority = priority
        @word_wrap = word_wrap
        @ellipsis = ellipsis
      end
    end
  end
end
