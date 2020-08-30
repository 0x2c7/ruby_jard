# frozen_string_literal: true

module RubyJard
  module Decorators
    ##
    # Decorate collection data structure. Support:
    # - Collection of values
    # - Collection of key-value pairs
    # - Individual value
    # - Individual pair
    # This decorator should not be used directly.
    class AttributesDecorator
      def initialize(general_decorator)
        @general_decorator = general_decorator
      end

      def inline_pairs(enum, total:, line_limit:, process_key:, value_proc: nil)
        spans = []
        width = 1
        item_limit = total == 0 ? 0 : [line_limit / total / 2, 30].max

        enum.each do |(key, value), index|
          key_inspection = inspect_key(key, item_limit, process_key: process_key)
          key_inspection_length = key_inspection.map(&:content_length).sum

          value_inspection = @general_decorator.decorate_singleline(
            value_proc.nil? ? value : value_proc.call(key), line_limit: [item_limit - key_inspection_length, 30].max
          )
          value_inspection_length = value_inspection.map(&:content_length).sum

          if index > 0
            spans << separator_span
            width += 2
          end

          if width + key_inspection_length + value_inspection_length + 5 > line_limit
            spans << ellipsis_span
            break
          end

          spans += key_inspection
          width += key_inspection_length

          spans << arrow_span
          width += 3

          spans += value_inspection
          width += value_inspection_length
        end

        spans
      end

      def inline_values(enum, total:, line_limit:)
        spans = []
        width = 1
        item_limit = total == 0 ? 0 : [line_limit / total / 2, 30].max

        enum.each do |value, index|
          value_inspection = @general_decorator.decorate_singleline(
            value, line_limit: [item_limit, 30].max
          )
          value_inspection_length = value_inspection.map(&:content_length).sum

          if index > 0
            spans << separator_span
            width += 2
          end

          if width + value_inspection_length + 2 > line_limit
            spans << ellipsis_span
            break
          end

          spans += value_inspection
          width += value_inspection_length
        end

        spans
      end

      def value(value, line_limit:)
        spans = []
        spans << indent_span
        width = indent_span.content_length

        value_inspection = @general_decorator.decorate_singleline(
          value, line_limit: [line_limit - width, 30].max
        )

        spans + value_inspection
      end

      def pair(key, value, line_limit:, process_key:)
        spans = []
        spans << indent_span
        width = indent_span.content_length

        key_inspection = inspect_key(key, line_limit - width, process_key: process_key)
        key_inspection_length = key_inspection.map(&:content_length).sum

        spans += key_inspection
        width += key_inspection_length

        spans << arrow_span
        width += 3

        value_inspection = @general_decorator.decorate_singleline(
          value, line_limit: [line_limit - width, 30].max
        )

        spans + value_inspection
      end

      private

      def inspect_key(key, item_limit, process_key:)
        if process_key
          @general_decorator.decorate_singleline(key, line_limit: item_limit)
        else
          [RubyJard::Span.new(content: key.to_s, styles: :text_secondary)]
        end
      end

      def arrow_span
        RubyJard::Span.new(content: '→', margin_left: 1, margin_right: 1, styles: :text_highlighted)
      end

      def separator_span
        RubyJard::Span.new(content: ',', margin_right: 1, styles: :text_secondary)
      end

      def ellipsis_span
        RubyJard::Span.new(content: '…', styles: :text_dim)
      end

      def indent_span
        RubyJard::Span.new(content: '▸', margin_right: 1, margin_left: 2, styles: :text_dim)
      end
    end
  end
end
