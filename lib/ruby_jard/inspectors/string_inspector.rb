# frozen_string_literal: true

module RubyJard
  module Inspectors
    ##
    # A light inspector for a string. String should be escaped, and cut off.
    class StringInspector
      include ::RubyJard::Span::DSL

      def initialize(base)
        @base = base
      end

      def match?(variable)
        RubyJard::Reflection.call_is_a?(variable, String)
      end

      # rubocop:disable Lint/UnusedMethodArgument
      def multiline(variable, first_line_limit:, line_limit:, lines:, depth: 0)
        [
          inline(variable, line_limit: first_line_limit)
        ]
      end

      def inline(variable, line_limit:, depth: 0)
        inspection = variable.inspect[1..-1].chomp!('"')
        str =
          if inspection.length < line_limit - 2
            inspection
          else
            inspection[0..line_limit - 4] + '…'
          end
        SimpleRow.new(
          text_string('"'),
          text_string(str),
          text_string('"')
        )
      end
      # rubocop:enable Lint/UnusedMethodArgument
    end
  end
end
