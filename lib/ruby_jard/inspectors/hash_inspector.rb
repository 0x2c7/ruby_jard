# frozen_string_literal: true

module RubyJard
  module Inspectors
    ##
    # Decorate Hash data structure, supports singleline and multiline form.
    class HashInspector
      include NestedHelper

      def initialize(base)
        @base = base
      end

      def singleline(variable, line_limit:, depth: 0)
        SimpleRow.new(
          RubyJard::Span.new(content: '{', styles: :text_primary),
          singleline_pairs(
            variable.each_with_index,
            total: variable.length, line_limit: line_limit - 2, process_key: true, depth: depth + 1
          ),
          RubyJard::Span.new(content: '}', styles: :text_primary)
        )
      end

      def multiline(variable, first_line_limit:, lines:, line_limit:, depth: 0)
        if variable.size > lines * 1.5
          return do_multiline(variable, lines: lines, line_limit: line_limit, depth: depth)
        elsif variable.length <= 1
          return [singleline(variable, line_limit: first_line_limit)]
        end

        singleline = singleline(variable, line_limit: first_line_limit)
        if singleline.content_length < line_limit
          [singleline]
        else
          do_multiline(variable, lines: lines, line_limit: line_limit, depth: depth)
        end
      end

      def match?(variable)
        RubyJard::Reflection.call_is_a?(variable, Hash)
      end

      private

      def do_multiline(variable, lines:, line_limit:, depth: 0)
        rows = [SimpleRow.new(RubyJard::Span.new(content: '{', styles: :text_primary))]

        item_count = 0
        variable.each_with_index do |(key, value), index|
          rows << multiline_pair(
            key, value, line_limit: line_limit, process_key: true, depth: depth + 1
          )
          item_count += 1
          break if index >= lines - 2
        end
        rows << last_line(variable.length, item_count)
      end

      def last_line(total, item_count)
        if total > item_count
          SimpleRow.new(
            RubyJard::Span.new(
              content: "▸ #{total - item_count} more...",
              margin_left: 2, styles: :text_dim
            ),
            RubyJard::Span.new(
              content: '}',
              styles: :text_primary
            )
          )
        else
          SimpleRow.new(RubyJard::Span.new(content: '}', styles: :text_primary))
        end
      end
    end
  end
end
