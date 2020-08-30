# frozen_string_literal: true

require 'ruby_jard/decorators/array_decorator'
require 'ruby_jard/decorators/string_decorator'
require 'ruby_jard/decorators/hash_decorator'
require 'ruby_jard/decorators/struct_decorator'
require 'ruby_jard/decorators/object_decorator'
require 'ruby_jard/decorators/attributes_decorator'
require 'ruby_jard/decorators/rails_decorator'

module RubyJard
  module Decorators
    ##
    # Generate beauty inspection of a particular variable.
    # The inspection doesn't aim to become a better version of PP. Instead,
    # it's scope is to generate an overview of a variable within a limited
    # space. So, it only keeps useful information, and tries to reach the
    # very shallow layers of a nested data structure.
    # This class is inspired by Ruby's PP:
    # https://github.com/ruby/ruby/blob/master/lib/pp.rb
    class InspectionDecorator
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
        //.class.name => :literal,
        (0..0).class.name => :literal,
        nil.class.name => :text_dim,
        Class.class.name => :text_secondary # Sorry, I lied, Class will never change
      }.freeze

      def initialize
        @klass_decorators = [
          @array_decorator = ArrayDecorator.new(self),
          @string_decorator = StringDecorator.new(self),
          @hash_decorator = HashDecorator.new(self),
          @struct_decorator = StructDecorator.new(self),
          @rails_decorator = RailsDecorator.new(self)
        ]
        @object_decorator = ObjectDecorator.new(self)
      end

      def decorate_singleline(variable, line_limit:)
        if primitive?(variable)
          return [
            RubyJard::Span.new(
              content: variable.inspect[0..line_limit - 1],
              styles: PRIMITIVE_TYPES[variable.class.name]
            )
          ]
        end

        @klass_decorators.each do |klass_decorator|
          next unless klass_decorator.match?(variable)

          spans = klass_decorator.decorate_singleline(variable, line_limit: line_limit)
          return spans unless spans.nil?
        end
        @object_decorator.decorate_singleline(variable, line_limit: line_limit)
      end

      def decorate_multiline(variable, first_line_limit:, lines:, line_limit:)
        if primitive?(variable)
          return [[
            RubyJard::Span.new(
              content: variable.inspect[0..first_line_limit - 1],
              styles: PRIMITIVE_TYPES[variable.class.name]
            )
          ]]
        end

        @klass_decorators.each do |klass_decorator|
          next unless klass_decorator.match?(variable)

          spans = klass_decorator.decorate_multiline(
            variable,
            first_line_limit: first_line_limit,
            lines: lines,
            line_limit: line_limit
          )
          return spans unless spans.nil?
        end
        @object_decorator.decorate_multiline(
          variable,
          first_line_limit: first_line_limit,
          lines: lines,
          line_limit: line_limit
        )
      end

      private

      def primitive?(variable)
        !PRIMITIVE_TYPES[variable.class.name].nil?
      end
    end
  end
end
