# frozen_string_literal: true

module RubyJard
  module Decorators
    ##
    # Default decorator for non-primitive data structure. It is aimed to replace default `inspect`.
    # If a variable re-implement `#inspect`, it hornors this decision, but still try to
    # parse the result.
    # Otherwise, it use `Kernel#to_s`, and try to push instance variables into the result.
    class ObjectDecorator
      DEFAULT_INSPECTION_PATTERN = /#<(.*:0x[0-9a-z]+)(.*)>/i.freeze

      def initialize(generic_decorator)
        @generic_decorator = generic_decorator
        @attributes_decorator = RubyJard::Decorators::AttributesDecorator.new(generic_decorator)
      end

      def decorate_singleline(variable, line_limit:, depth: 0)
        if native_inspect?(variable)
          decorate_native_inspection(variable, line_limit: line_limit, depth: depth)
        else
          decorate_custom_inspection(variable, line_limit: line_limit)
        end
      end

      def decorate_multiline(variable, first_line_limit:, lines:, line_limit:, depth: 0)
        singleline = decorate_singleline(variable, line_limit: first_line_limit)
        return [singleline] if singleline.map(&:content_length).sum < line_limit

        spans = [decorate_native_inspection(variable, line_limit: first_line_limit, with_children: false)]

        item_count = 0
        instance_variables = RubyJard::Reflection.call_instance_variables(variable)
        instance_variables.each do |key|
          spans << @attributes_decorator.pair(
            key, RubyJard::Reflection.call_instance_variable_get(variable, key),
            line_limit: line_limit, process_key: false, depth: depth + 1
          )

          item_count += 1
          break if item_count >= lines - 2
        end

        if instance_variables.length > item_count
          spans << [
            RubyJard::Span.new(
              content: "▸ #{instance_variables.length - item_count} more...",
              margin_left: 2, styles: :text_dim
            )
          ]
        end

        spans
      end

      private

      def native_inspect?(variable)
        return true unless RubyJard::Reflection.call_respond_to?(variable, :inspect)

        RubyJard::Reflection.bind_call(::Kernel, :method, variable, :inspect).owner == ::Kernel
      end

      def decorate_native_inspection(variable, line_limit:, depth: 0, with_children: true)
        raw_inspection = RubyJard::Reflection.call_to_s(variable)
        match = raw_inspection.match(DEFAULT_INSPECTION_PATTERN)

        if match
          instance_variables = RubyJard::Reflection.call_instance_variables(variable)
          spans = [
            RubyJard::Span.new(content: '#<', styles: :text_secondary),
            RubyJard::Span.new(content: match[1], styles: :text_secondary)
          ]
          if with_children && !instance_variables.empty?
            spans << RubyJard::Span.new(content: ' ', styles: :text_secondary)
            spans += @attributes_decorator.inline_pairs(
              instance_variables.each_with_index, total: instance_variables.length,
              line_limit: line_limit - spans.map(&:content_length).sum - 1,
              depth: depth + 1, process_key: false,
              value_proc: ->(key) { RubyJard::Reflection.call_instance_variable_get(variable, key) }
            )
          end
          spans << RubyJard::Span.new(content: '>', styles: :text_secondary)
          spans
        elsif raw_inspection.length <= line_limit
          [RubyJard::Span.new(content: raw_inspection[0..line_limit], styles: :text_secondary)]
        else
          [RubyJard::Span.new(content: raw_inspection[0..line_limit - 3] + '…>', styles: :text_secondary)]
        end
      end

      def decorate_custom_inspection(variable, line_limit:)
        raw_inspection = variable.inspect
        match = raw_inspection.match(DEFAULT_INSPECTION_PATTERN)
        if match
          detail =
            if match[2].length < line_limit - match[1].length - 3
              match[2]
            else
              match[2][0..line_limit - match[1].length - 4] + '…'
            end
          [
            RubyJard::Span.new(content: '#<', styles: :text_secondary),
            RubyJard::Span.new(content: match[1], styles: :text_secondary),
            RubyJard::Span.new(content: detail, styles: :text_dim),
            RubyJard::Span.new(content: '>', styles: :text_secondary)
          ]
        elsif raw_inspection.length <= line_limit
          [RubyJard::Span.new(content: raw_inspection[0..line_limit], styles: :text_secondary)]
        else
          [RubyJard::Span.new(content: raw_inspection[0..line_limit - 3] + '…>', styles: :text_secondary)]
        end
      end
    end
  end
end
