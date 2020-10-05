# frozen_string_literal: true

module RubyJard
  module Inspectors
    ##
    # Inspector for Struct.
    # TODO: This one should handle Open Struct too
    class StructInspector
      include NestedHelper
      include ::RubyJard::Span::DSL

      def initialize(base)
        @base = base
      end

      def match?(variable)
        RubyJard::Reflection.call_is_a?(variable, Struct)
      end

      def inline(variable, line_limit:, depth: 0)
        row = SimpleRow.new(text_dim('#<struct '))
        unless variable.class.name.nil?
          row << text_primary(variable.class.name.to_s)
          row << text_primary(' ')
        end
        row << inline_pairs(
          variable.members.each_with_index,
          total: variable.length, line_limit: line_limit - row.content_length - 1,
          process_key: false, depth: depth + 1,
          value_proc: ->(key) { variable[key] }
        )
        row << text_dim('>')
      end

      def multiline(variable, lines:, line_limit:, depth: 0)
        if variable.size > lines * 1.5
          return do_multiline(variable, lines: lines, line_limit: line_limit, depth: depth)
        end

        inline = inline(variable, line_limit: line_limit * 2)

        if inline.content_length < line_limit || variable.length <= 1
          [inline]
        else
          do_multiline(variable, lines: lines, line_limit: line_limit, depth: depth)
        end
      end

      private

      def do_multiline(variable, lines:, line_limit:, depth: 0)
        rows = []
        start = SimpleRow.new(text_dim('#<struct'))
        unless variable.class.name.nil?
          start << text_primary(' ')
          start << text_primary(variable.class.name.to_s)
        end
        start << text_dim('>')
        rows << start

        item_count = 0
        variable.members.each_with_index do |member, index|
          rows << multiline_pair(
            member, variable[member], line_limit: line_limit, process_key: false, depth: depth + 1
          )
          item_count += 1
          break if index >= lines - 2
        end
        rows << last_line(variable.length, item_count) if variable.length > item_count
        rows
      end

      def last_line(total, item_count)
        SimpleRow.new(text_dim("  ▸ #{total - item_count} more..."))
      end
    end
  end
end
