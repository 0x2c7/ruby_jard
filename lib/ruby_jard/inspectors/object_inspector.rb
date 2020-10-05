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

      DEFAULT_INSPECTION_PATTERN = /#<(.*:0x[0-9a-z]+)(.*)>/i.freeze

      def initialize(base)
        @base = base
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

      def multiline(variable, first_line_limit:, lines:, line_limit:, depth: 0)
        inline = inline(variable, line_limit: first_line_limit)
        return [inline] if inline.content_length < line_limit

        rows = [decorate_native_inspection(variable, line_limit: first_line_limit, with_children: false)]

        item_count = 0
        instance_variables = RubyJard::Reflection.call_instance_variables(variable)
        instance_variables.each do |key|
          rows << multiline_pair(
            key, RubyJard::Reflection.call_instance_variable_get(variable, key),
            line_limit: line_limit, process_key: false, depth: depth + 1
          )

          item_count += 1
          break if item_count >= lines - 2
        end

        if instance_variables.length > item_count
          rows << SimpleRow.new(
            RubyJard::Span.new(
              content: "▸ #{instance_variables.length - item_count} more...",
              margin_left: 2, styles: :text_dim
            )
          )
        end

        rows
      end

      private

      def native_inspect?(variable)
        return true unless RubyJard::Reflection.call_respond_to?(variable, :inspect)

        RubyJard::Reflection.bind_call(::Kernel, :method, variable, :inspect).owner == ::Kernel
      end

      def call_inspect(variable)
        variable.inspect
      rescue StandardError
        RubyJard::Reflection.call_to_s(variable)
      end

      def decorate_native_inspection(variable, line_limit:, depth: 0, with_children: true)
        raw_inspection = RubyJard::Reflection.call_to_s(variable)
        match = raw_inspection.match(DEFAULT_INSPECTION_PATTERN)

        if match
          instance_variables = RubyJard::Reflection.call_instance_variables(variable)
          row = SimpleRow.new(
            RubyJard::Span.new(content: '#<', styles: :text_primary),
            RubyJard::Span.new(content: match[1], styles: :text_primary)
          )
          if with_children && !instance_variables.empty?
            row << RubyJard::Span.new(content: ' ', styles: :text_primary)
            row << inline_pairs(
              instance_variables.each_with_index, total: instance_variables.length,
              line_limit: line_limit - row.content_length - 1,
              depth: depth + 1, process_key: false,
              value_proc: ->(key) { RubyJard::Reflection.call_instance_variable_get(variable, key) }
            )
          end
          row << RubyJard::Span.new(content: '>', styles: :text_primary)
        elsif raw_inspection.length <= line_limit
          SimpleRow.new(RubyJard::Span.new(content: raw_inspection[0..line_limit], styles: :text_primary))
        else
          SimpleRow.new(RubyJard::Span.new(content: raw_inspection[0..line_limit - 3] + '…>', styles: :text_primary))
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
            RubyJard::Span.new(content: '#<', styles: :text_primary),
            RubyJard::Span.new(content: match[1], styles: :text_primary),
            RubyJard::Span.new(content: detail, styles: :text_dim),
            RubyJard::Span.new(content: '>', styles: :text_primary)
          )
        elsif raw_inspection.length <= line_limit
          SimpleRow.new(RubyJard::Span.new(content: raw_inspection[0..line_limit], styles: :text_primary))
        else
          SimpleRow.new(RubyJard::Span.new(content: raw_inspection[0..line_limit - 3] + '…>', styles: :text_primary))
        end
      end
    end
  end
end
