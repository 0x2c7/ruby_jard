# frozen_string_literal: true

module RubyJard
  module Decorators
    ##
    # Decorator for Struct.
    # TODO: This one should handle Open Struct too
    class StructDecorator
      def initialize(generic_decorator)
        @generic_decorator = generic_decorator
        @attributes_decorator = RubyJard::Decorators::AttributesDecorator.new(generic_decorator)
      end

      def match?(variable)
        RubyJard::Reflection.call_is_a?(variable, Struct)
      end

      def decorate_singleline(variable, line_limit:, depth: 0)
        spans = [RubyJard::Span.new(content: '#<struct', margin_right: 1, styles: :text_dim)]
        unless variable.class.name.nil?
          spans << RubyJard::Span.new(content: variable.class.name.to_s, margin_right: 1, styles: :text_primary)
        end
        spans += @attributes_decorator.inline_pairs(
          variable.members.each_with_index,
          total: variable.length, line_limit: line_limit - spans.map(&:content_length).sum - 1,
          process_key: false, depth: depth + 1,
          value_proc: ->(key) { variable[key] }
        )
        spans << RubyJard::Span.new(content: '>', styles: :text_dim)
      end

      def decorate_multiline(variable, first_line_limit:, lines:, line_limit:, depth: 0)
        if variable.size > lines * 1.5
          return do_decorate_multiline(variable, lines: lines, line_limit: line_limit, depth: depth)
        end

        singleline = decorate_singleline(variable, line_limit: first_line_limit)

        if singleline.map(&:content_length).sum < line_limit || variable.length <= 1
          [singleline]
        else
          do_decorate_multiline(variable, lines: lines, line_limit: line_limit, depth: depth)
        end
      end

      private

      def do_decorate_multiline(variable, lines:, line_limit:, depth: 0)
        spans = []
        start = [RubyJard::Span.new(content: '#<struct', styles: :text_dim)]
        unless variable.class.name.nil?
          start << RubyJard::Span.new(content: variable.class.name.to_s, margin_left: 1, styles: :text_primary)
        end
        start << RubyJard::Span.new(content: '>', styles: :text_dim)
        spans << start

        item_count = 0
        variable.members.each_with_index do |member, index|
          spans << @attributes_decorator.pair(
            member, variable[member], line_limit: line_limit, process_key: false, depth: depth + 1
          )
          item_count += 1
          break if index >= lines - 2
        end
        spans << last_line(variable.length, item_count) if variable.length > item_count
        spans
      end

      def last_line(total, item_count)
        [
          RubyJard::Span.new(
            content: "▸ #{total - item_count} more...",
            margin_left: 2, styles: :text_dim
          )
        ]
      end
    end
  end
end
