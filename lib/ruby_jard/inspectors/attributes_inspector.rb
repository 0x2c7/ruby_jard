# frozen_string_literal: true

module RubyJard
  module Inspectors
    TYPICAL_DEPTH = 3
    MAX_DEPTH = 5
    DO_NOT_WASTE_LENGTH = 40
    ##
    # Decorate collection data structure. Support:
    # - Collection of values
    # - Collection of key-value pairs
    # - Individual value
    # - Individual pair
    # This inspector should not be used directly.
    class AttributesInspector
      def initialize(base)
        @base = base
      end

      def inline_pairs(enum, total:, line_limit:, process_key:, value_proc: nil, depth: 0)
        return SimpleRow.new(ellipsis_span) if too_deep?(depth, line_limit)

        row = SimpleRow.new
        item_limit = total == 0 ? 0 : pair_limit(depth, line_limit / total)

        enum.each do |(key, value), index|
          key_inspection = inspect_key(key, item_limit, process_key: process_key, depth: depth)
          value_inspection = @base.singleline(
            value_proc.nil? ? value : value_proc.call(key),
            line_limit: pair_limit(depth, item_limit - key_inspection.content_length), depth: depth
          )

          row << separator_span if index > 0

          if row.content_length + key_inspection.content_length + value_inspection.content_length + 6 > line_limit
            row << ellipsis_span
            break
          end

          row << key_inspection
          row << arrow_span
          row << value_inspection
        end

        row
      end

      def pair(key, value, line_limit:, process_key:, depth: 0)
        return SimpleRow.new(ellipsis_span) if too_deep?(depth, line_limit)

        row = SimpleRow.new
        row << indent_span

        key_inspection = inspect_key(
          key,
          line_limit - indent_span.content_length,
          process_key: process_key, depth: depth
        )

        row << key_inspection
        row << arrow_span
        value_inspection = @base.singleline(
          value, line_limit: pair_limit(depth, line_limit - row.content_length), depth: depth
        )

        row << value_inspection
      end

      def inline_values(enum, total:, line_limit:, depth: 0)
        return SimpleRow.new(ellipsis_span) if too_deep?(depth, line_limit)

        row = SimpleRow.new
        item_limit = total == 0 ? 0 : value_limit(line_limit / total)

        enum.each do |value, index|
          value_inspection = @base.singleline(
            value, line_limit: value_limit(item_limit), depth: depth
          )

          row << separator_span if index > 0

          if row.content_length + value_inspection.content_length + 2 > line_limit
            row << ellipsis_span
            break
          end

          row << value_inspection
        end

        row
      end

      def value(value, line_limit:, depth: 0)
        return [ellipsis_span] if too_deep?(depth, line_limit)

        row = SimpleRow.new
        row << indent_span
        value_inspection = @base.singleline(
          value, line_limit: value_limit(line_limit - row.content_length), depth: depth
        )

        row << value_inspection
      end

      private

      def inspect_key(key, item_limit, process_key:, depth: 0)
        if process_key
          @base.singleline(
            key, line_limit: item_limit, depth: depth
          )
        else
          SimpleRow.new(RubyJard::Span.new(content: key.to_s, styles: :text_primary))
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

      def pair_limit(depth, desired)
        # The deeper structure, the less meaningful the actual data is
        [30 - depth * 5, desired].max
      end

      def value_limit(desired)
        [30, desired].max
      end
    end
  end
end
