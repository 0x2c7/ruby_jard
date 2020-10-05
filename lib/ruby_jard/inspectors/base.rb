# frozen_string_literal: true

require 'ruby_jard/inspectors/nested_helper'
require 'ruby_jard/inspectors/primitive_inspector'
require 'ruby_jard/inspectors/array_inspector'
require 'ruby_jard/inspectors/string_inspector'
require 'ruby_jard/inspectors/hash_inspector'
require 'ruby_jard/inspectors/struct_inspector'
require 'ruby_jard/inspectors/object_inspector'
require 'ruby_jard/inspectors/rails_inspectors'

module RubyJard
  module Inspectors
    ##
    # Generate beauty inspection of a particular variable.
    # This class is a specialized decorator.
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
          ArrayInpsector.new(self),
          StringInspector.new(self),
          HashInspector.new(self),
          StructInspector.new(self),
          ActiveRecordBaseInspector.new(self),
          ActiveRecordRelationInspector.new(self),
          ObjectInspector.new(self)
        ]
      end

      def inline(variable, line_limit:, depth: 0)
        @inspectors.each do |inspector|
          next unless inspector.match?(variable)

          row = inspector.inline(variable, line_limit: line_limit, depth: depth)
          return row unless row.nil?
        end
        SimpleRow.new(Span.new(content: '???', styles: :text_primary))
      end

      def multiline(variable, first_line_limit:, lines:, line_limit:, depth: 0)
        @inspectors.each do |inspector|
          next unless inspector.match?(variable)

          rows = inspector.multiline(
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
