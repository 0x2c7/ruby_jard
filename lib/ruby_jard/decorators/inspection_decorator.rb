# frozen_string_literal: true

require 'ruby_jard/decorators/primitive_inspector'
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
      def initialize
        # Order matters here. Primitive has highest priority, object is the last fallback
        @inspectors = [
          PrimitiveInspector.new(self),
          ArrayDecorator.new(self),
          StringDecorator.new(self),
          HashDecorator.new(self),
          StructDecorator.new(self),
          RailsDecorator.new(self),
          ObjectDecorator.new(self)
        ]
      end

      def decorate_singleline(variable, line_limit:, depth: 0)
        @inspectors.each do |inspector|
          next unless inspector.match?(variable)

          row = inspector.decorate_singleline(variable, line_limit: line_limit, depth: depth)
          return row unless row.nil?
        end
        SimpleRow.new(Span.new(content: '???', styles: :text_primary))
      end

      def decorate_multiline(variable, first_line_limit:, lines:, line_limit:, depth: 0)
        @inspectors.each do |inspector|
          next unless inspector.match?(variable)

          rows = inspector.decorate_multiline(
            variable,
            first_line_limit: first_line_limit,
            lines: lines,
            line_limit: line_limit,
            depth: depth
          )
          return rows unless rows.nil?
        end
        [SimpleRow.new(Span.new(content: '???', styles: :text_primary))]
      end
    end
  end
end
