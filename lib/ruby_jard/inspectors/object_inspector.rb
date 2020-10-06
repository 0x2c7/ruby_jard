# frozen_string_literal: true

module RubyJard
  module Inspectors
    ##
    # Default decorator for non-primitive data structure. It is aimed to replace default `inspect`.
    # If a variable re-implement `#inspect`, it hornors this decision, but still try to
    # parse the result.
    # Otherwise, it use `Kernel#to_s`, and try to push instance variables into the result.
    class ObjectInspector
      include NestedHelper
      include ::RubyJard::Span::DSL

      DEFAULT_INSPECTION_PATTERN = /#<(.*:0x[0-9a-z]+)(.*)>/i.freeze

      def initialize(base)
        @base = base
        @reflection = RubyJard::Reflection.instance
      end

      def match?(_variable)
        true
      end

      def inline(variable, line_limit:, depth: 0)
        if native_inspect?(variable)
          decorate_native_inspection(variable, line_limit: line_limit, depth: depth)
        else
          decorate_custom_inspection(variable, line_limit: line_limit)
        end
      end

      def multiline(variable, lines:, line_limit:, depth: 0)
        inline = inline(variable, line_limit: line_limit * 2)
        return [inline] if inline.content_length < line_limit

        rows = [decorate_native_inspection(variable, line_limit: line_limit * 2, with_children: false)]

        item_count = 0
        instance_variables = @reflection.call_instance_variables(variable)
        instance_variables.each do |key|
          rows << multiline_pair(
            key, @reflection.call_instance_variable_get(variable, key),
            line_limit: line_limit, process_key: false, depth: depth + 1
          )

          item_count += 1
          break if item_count >= lines - 2
        end

        if instance_variables.length > item_count
          rows << SimpleRow.new(text_dim("  ▸ #{instance_variables.length - item_count} more..."))
        end

        rows
      end

      private

      def native_inspect?(variable)
        return true unless @reflection.call_respond_to?(variable, :inspect)

        @reflection.call_method(variable, :inspect).owner == ::Kernel
      end

      def call_inspect(variable)
        variable.inspect
      rescue StandardError
        @reflection.call_to_s(variable)
      end

      def decorate_native_inspection(variable, line_limit:, depth: 0, with_children: true)
        raw_inspection = @reflection.call_to_s(variable)
        match = raw_inspection.match(DEFAULT_INSPECTION_PATTERN)

        if match
          instance_variables = @reflection.call_instance_variables(variable)
          row = SimpleRow.new(
            text_primary('#<'),
            text_primary(match[1])
          )
          if with_children && !instance_variables.empty?
            row << text_primary(' ')
            row << inline_pairs(
              instance_variables.each_with_index, total: instance_variables.length,
              line_limit: line_limit - row.content_length - 1,
              depth: depth + 1, process_key: false,
              value_proc: ->(key) { @reflection.call_instance_variable_get(variable, key) }
            )
          end
          row << text_primary('>')
        elsif raw_inspection.length <= line_limit
          SimpleRow.new(text_primary(raw_inspection[0..line_limit]))
        else
          SimpleRow.new(text_primary(raw_inspection[0..line_limit - 3] + '…>'))
        end
      end

      def decorate_custom_inspection(variable, line_limit:)
        raw_inspection = call_inspect(variable)
        match = raw_inspection.match(DEFAULT_INSPECTION_PATTERN)
        if match
          detail =
            if match[2].length < line_limit - match[1].length - 3
              match[2]
            else
              match[2][0..line_limit - match[1].length - 4] + '…'
            end
          SimpleRow.new(
            text_primary('#<'),
            text_primary(match[1]),
            text_dim(detail),
            text_primary('>')
          )
        elsif raw_inspection.length <= line_limit
          SimpleRow.new(text_primary(raw_inspection[0..line_limit]))
        else
          SimpleRow.new(text_primary(raw_inspection[0..line_limit - 3] + '…>'))
        end
      end
    end
  end
end
