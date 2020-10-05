# frozen_string_literal: true

module RubyJard
  module Inpsectors
    ##
    # A light decorator for a string. String should be escaped, and cut off.
    class StringDecorator
      def initialize(generic_decorator)
        @generic_decorator = generic_decorator
      end

      def match?(variable)
        RubyJard::Reflection.call_is_a?(variable, String)
      end

      # rubocop:disable Lint/UnusedMethodArgument
      def decorate_multiline(variable, first_line_limit:, line_limit:, lines:, depth: 0)
        [
          decorate_singleline(variable, line_limit: first_line_limit)
        ]
      end

      def decorate_singleline(variable, line_limit:, depth: 0)
        inspection = variable.inspect[1..-1].chomp!('"')
        str =
          if inspection.length < line_limit - 2
            inspection
          else
            inspection[0..line_limit - 4] + '…'
          end
        SimpleRow.new(
          RubyJard::Span.new(content: '"', styles: :string),
          RubyJard::Span.new(content: str, styles: :string),
          RubyJard::Span.new(content: '"', styles: :string)
        )
      end
      # rubocop:enable Lint/UnusedMethodArgument
    end
  end
end
