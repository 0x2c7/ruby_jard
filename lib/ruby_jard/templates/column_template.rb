# frozen_string_literal: true

module RubyJard
  module Templates
    ##
    # Template for a column. All items in a column align with each other. A column includes one or more spans.
    class ColumnTemplate
      attr_reader :spans, :margin_right, :margin_left

      def initialize(spans: [], margin_left: 0, margin_right: 0)
        @spans = spans
        @margin_left = margin_left
        @margin_right = margin_right
      end
    end
  end
end
