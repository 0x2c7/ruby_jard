# frozen_string_literal: true

module RubyJard
  module Inspectors
    # Inpsect Ruby primitive types
    class PrimitiveInspector
      PRIMITIVE_TYPES = {
        # Intertal classes for those values may differ between Ruby versions
        # For example: Bignum is renamed to Integer
        # So, it's safer to use discrete value's class as the key for this mapping.
        true.class.name => :literal,
        false.class.name => :literal,
        1.class.name => :literal,
        1.1.class.name => :literal,
        1.to_r.class.name => :literal, # Rational: (1/1)
        1.to_c.class.name => :literal, # Complex: (1+0i)
        :sym.class.name => :literal,
        //.class.name => :literal, # TODO: create a new class to handle range
        (0..0).class.name => :literal,
        nil.class.name => :text_dim,
        Class.class.name => :text_primary, # Sorry, I lied, Class will never change
        Proc.name => :text_primary # TODO: create a new class to handle proc.
      }.freeze

      def initialize(_inspector); end

      def match?(variable)
        !PRIMITIVE_TYPES[RubyJard::Reflection.call_class(variable).name].nil?
      end

      # rubocop:disable Lint/UnusedMethodArgument
      def inline(variable, line_limit:, depth:)
        inspection = variable.inspect
        inspection = inspection[0..line_limit - 2] + '…' if inspection.length >= line_limit
        SimpleRow.new(
          RubyJard::Span.new(
            content: inspection,
            styles: PRIMITIVE_TYPES[RubyJard::Reflection.call_class(variable).name]
          )
        )
      end

      def multiline(variable, lines:, line_limit:, depth: 0)
        [inline(variable, line_limit: line_limit * 2, depth: depth)]
      end
      # rubocop:enable Lint/UnusedMethodArgument
    end
  end
end
