# frozen_string_literal: true

require 'ruby_jard/inspectors/primitive_inspector'
require 'ruby_jard/inspectors/array_decorator'
require 'ruby_jard/inspectors/string_decorator'
require 'ruby_jard/inspectors/hash_decorator'
require 'ruby_jard/inspectors/struct_decorator'
require 'ruby_jard/inspectors/object_decorator'
require 'ruby_jard/inspectors/attributes_decorator'
require 'ruby_jard/inspectors/rails_decorator'

module RubyJard
  module Inpsectors
    ##
    # Generate beauty inspection of a particular variable.
    # This class is a specialized decorator
    # The inspection doesn't aim to become a better version of PP. Instead,
    # it's scope is to generate an overview of a variable within a limited
    # space. So, it only keeps useful information, and tries to reach the
    # very shallow layers of a nested data structure.
    # This class is inspired by Ruby's PP:
    # https://github.com/ruby/ruby/blob/master/lib/pp.rb
    class Base
      def initialize
        # Order matters here. Primitive has highest priority, object is the last fallback
        @inspectors = [
          PrimitiveInspector.new(self),
          ArrayDecorator.new(self),
          StringDecorator.new(self),
          HashDecorator.new(self),
          StructDecorator.new(self),
          ActiveRecordBaseDecorator.new(self),
          ActiveRecordRelationDecorator.new(self),
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
