# frozen_string_literal: true

module RubyJard
  class StructDecorator
    def initialize(general_decorator)
      @general_decorator = general_decorator
      @attributes_decorator = RubyJard::Decorators::AttributesDecorator.new(general_decorator)
    end

    def match?(variable)
      variable.is_a?(Struct)
    end

    def decorate_singleline(variable, line_limit:)
      spans = [RubyJard::Span.new(content: '#<struct ', styles: :text_secondary)]
      unless variable.class.name.nil?
        spans << RubyJard::Span.new(content: variable.class.name.to_s, styles: :text_secondary)
      end
      spans += @attributes_decorator.inline_pairs(
        variable.members.each_with_index,
        total: variable.length, line_limit: line_limit - spans.map(&:content_length).sum - 1, process_key: false,
        value_proc: ->(key) { variable[key] }
      )
      spans << RubyJard::Span.new(content: '>', styles: :text_secondary)
    end

    def decorate_multiline(variable, first_line_limit:, lines:, line_limit:)
      singleline = decorate_singleline(variable, line_limit: first_line_limit)

      if singleline.map(&:content_length).sum < line_limit || variable.length <= 1
        [singleline]
      else
        spans = []
        start = [RubyJard::Span.new(content: '#<struct ', styles: :text_secondary)]
        unless variable.class.name.nil?
          start << RubyJard::Span.new(content: variable.class.name.to_s, styles: :text_secondary)
        end
        start << RubyJard::Span.new(content: '>', styles: :text_secondary)
        spans << start

        item_count = 0
        variable.members.each_with_index do |member, index|
          spans << @attributes_decorator.pair(
            member, variable[member], line_limit: line_limit, process_key: false
          )
          item_count += 1
          break if index >= lines - 2
        end
        spans << last_line(variable.length, item_count) if variable.length > item_count
        spans
      end
    end

    private

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
