# frozen_string_literal: true

module RubyJard
  module Decorators
    TYPICAL_DEPTH = 3
    MAX_DEPTH = 5
    DO_NOT_WASTE_LENGTH = 40
    ##
    # Decorate collection data structure. Support:
    # - Collection of values
    # - Collection of key-value pairs
    # - Individual value
    # - Individual pair
    # This decorator should not be used directly.
    class AttributesDecorator
      def initialize(generic_decorator)
        @generic_decorator = generic_decorator
      end

      def inline_pairs(enum, total:, line_limit:, process_key:, value_proc: nil, depth: 0)
        return [ellipsis_span] if too_deep?(depth, line_limit)

        spans = []
        width = 1
        item_limit = total == 0 ? 0 : [line_limit / total, pair_limit(depth)].max

        enum.each do |(key, value), index|
          key_inspection = inspect_key(key, item_limit, process_key: process_key, depth: depth)
          key_inspection_length = key_inspection.map(&:content_length).sum

          value_inspection = @generic_decorator.decorate_singleline(
            value_proc.nil? ? value : value_proc.call(key),
            line_limit: [item_limit - key_inspection_length, pair_limit(depth)].max, depth: depth
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

      def pair(key, value, line_limit:, process_key:, depth: 0)
        return [ellipsis_span] if too_deep?(depth, line_limit)

        spans = []
        spans << indent_span
        width = indent_span.content_length

        key_inspection = inspect_key(key, line_limit - width, process_key: process_key, depth: depth)
        key_inspection_length = key_inspection.map(&:content_length).sum

        spans += key_inspection
        width += key_inspection_length

        spans << arrow_span
        width += 3

        value_inspection = @generic_decorator.decorate_singleline(
          value, line_limit: [line_limit - width, pair_limit(depth)].max, depth: depth
        )

        spans + value_inspection
      end

      def inline_values(enum, total:, line_limit:, depth: 0)
        return [ellipsis_span] if too_deep?(depth, line_limit)

        spans = []
        width = 1
        item_limit = total == 0 ? 0 : [line_limit / total, value_limit(depth)].max

        enum.each do |value, index|
          value_inspection = @generic_decorator.decorate_singleline(
            value, line_limit: [item_limit, value_limit(depth)].max, depth: depth
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

      def value(value, line_limit:, depth: 0)
        return [ellipsis_span] if too_deep?(depth, line_limit)

        spans = []
        spans << indent_span
        width = indent_span.content_length

        value_inspection = @generic_decorator.decorate_singleline(
          value, line_limit: [line_limit - width, value_limit(depth)].max, depth: depth
        )

        spans + value_inspection
      end

      private

      def inspect_key(key, item_limit, process_key:, depth: 0)
        if process_key
          @generic_decorator.decorate_singleline(
            key, line_limit: item_limit, depth: depth
          )
        else
          [RubyJard::Span.new(content: key.to_s, styles: :text_primary)]
        end
      end

      def arrow_span
        RubyJard::Span.new(content: '→', margin_left: 1, margin_right: 1, styles: :text_highlighted)
      end

      def separator_span
        RubyJard::Span.new(content: ',', margin_right: 1, styles: :text_primary)
      end

      def ellipsis_span
        RubyJard::Span.new(content: '…', styles: :text_dim)
      end

      def indent_span
        RubyJard::Span.new(content: '▸', margin_right: 1, margin_left: 2, styles: :text_dim)
      end

      def too_deep?(depth, line_limit)
        return true if depth > MAX_DEPTH
        return false if line_limit > DO_NOT_WASTE_LENGTH

        depth > TYPICAL_DEPTH
      end

      def pair_limit(depth)
        # The deeper structure, the less meaningful the actual data is
        30 - depth * 5
      end

      def value_limit(_depth)
        30
      end
    end
  end
end
