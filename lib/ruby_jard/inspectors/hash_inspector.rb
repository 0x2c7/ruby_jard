# frozen_string_literal: true

module RubyJard
  module Inspectors
    ##
    # Decorate Hash data structure, supports inline and multiline form.
    class HashInspector
      include NestedHelper
      include ::RubyJard::Span::DSL

      def initialize(base)
        @base = base
      end

      def inline(variable, line_limit:, depth: 0)
        SimpleRow.new(
          text_primary('{'),
          inline_pairs(
            variable.each_with_index,
            total: variable.length, line_limit: line_limit - 2, process_key: true, depth: depth + 1
          ),
          text_primary('}')
        )
      end

      def multiline(variable, first_line_limit:, lines:, line_limit:, depth: 0)
        if variable.size > lines * 1.5
          return do_multiline(variable, lines: lines, line_limit: line_limit, depth: depth)
        elsif variable.length <= 1
          return [inline(variable, line_limit: first_line_limit)]
        end

        inline = inline(variable, line_limit: first_line_limit)
        if inline.content_length < line_limit
          [inline]
        else
          do_multiline(variable, lines: lines, line_limit: line_limit, depth: depth)
        end
      end

      def match?(variable)
        RubyJard::Reflection.call_is_a?(variable, Hash)
      end

      private

      def do_multiline(variable, lines:, line_limit:, depth: 0)
        rows = [SimpleRow.new(text_primary('{'))]

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
            text_dim("  ▸ #{total - item_count} more..."),
            text_primary('}')
          )
        else
          SimpleRow.new(text_primary('}'))
        end
      end
    end
  end
end
