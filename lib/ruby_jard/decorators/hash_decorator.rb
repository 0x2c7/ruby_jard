# frozen_string_literal: true

module RubyJard
  class HashDecorator
    def initialize(general_decorator)
      @general_decorator = general_decorator
    end

    def decorate_singleline(variable, line_limit:)
      spans = [RubyJard::Span.new(content: '{', styles: :text_secondary)]

      width = 1
      variable.each_with_index do |(key, value), index|
        item_limit = [line_limit / variable.length / 2, 30].max

        key_inspection = @general_decorator.decorate_singleline(key, line_limit: item_limit)
        key_inspection_length = key_inspection.map(&:content_length).sum

        value_inspection = @general_decorator.decorate_singleline(
          value, line_limit: [item_limit - key_inspection_length, 30].max
        )
        value_inspection_length = value_inspection.map(&:content_length).sum

        if index > 0
          spans << RubyJard::Span.new(content: ',', margin_right: 1, styles: :text_secondary)
          width += 2
        end

        if width + key_inspection_length + value_inspection_length + 5 > line_limit
          spans << RubyJard::Span.new(content: '…', styles: :text_dim)
          break
        end

        spans << key_inspection
        width += key_inspection_length

        spans << RubyJard::Span.new(content: '→', margin_left: 1, margin_right: 1, styles: :text_highlighted)
        width += 3

        spans << value_inspection
        width += value_inspection_length
      end
      spans << RubyJard::Span.new(content: '}', styles: :text_secondary)
      spans.flatten
    end

    def decorate_multiline(variable, first_line_limit:, lines:, line_limit:)
      singleline = decorate_singleline(variable, line_limit: first_line_limit)
      if singleline.map(&:content_length).sum < line_limit || variable.length <= 1
        [singleline]
      else
        spans = [[RubyJard::Span.new(content: '{', styles: :text_secondary)]]

        item_count = 0
        variable.each_with_index do |(key, value), index|
          line = []
          line << RubyJard::Span.new(content: '▸', margin_right: 1, margin_left: 2, styles: :text_dim)

          key_inspection = @general_decorator.decorate_singleline(key, line_limit: line_limit - 4)
          key_inspection_length = key_inspection.map(&:content_length).length

          line += key_inspection
          line << RubyJard::Span.new(content: '→', margin_right: 1, margin_left: 1, styles: :text_highlighted)
          line += @general_decorator.decorate_singleline(value, line_limit: line_limit - 4 - key_inspection_length)

          spans << line
          item_count += 1
          break if index >= lines - 2
        end
        spans << last_line(variable.length, item_count)
      end
    end

    def match?(variable)
      variable.is_a?(Hash)
    end

    def last_line(total, item_count)
      if total > item_count
        [
          RubyJard::Span.new(
            content: "▸ #{total - item_count} more...",
            margin_left: 2, styles: :text_dim
          ),
          RubyJard::Span.new(
            content: '}',
            styles: :text_secondary
          )
        ]
      else
        [RubyJard::Span.new(content: '}', styles: :text_secondary)]
      end
    end
  end
end
