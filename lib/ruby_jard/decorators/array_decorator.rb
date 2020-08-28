# frozen_string_literal: true

module RubyJard
  class ArrayDecorator
    def initialize(inspection_decorator)
      @inspection_decorator = inspection_decorator
    end

    def decorate_singleline(variable, line_limit:)
      spans = [RubyJard::Span.new(content: '[', styles: :text_secondary)]

      width = 1
      variable.each_with_index do |item, index|
        item_limit = [line_limit / variable.length, 30].max

        inspection = @inspection_decorator.decorate_singleline(item, line_limit: item_limit)
        inspection_length = inspection.map(&:content_length).sum

        if index > 0
          spans << RubyJard::Span.new(content: ',', margin_right: 1, styles: :text_secondary)
          width += 2
        end

        if width + inspection_length + 2 >= line_limit
          spans << RubyJard::Span.new(content: '…', styles: :text_dim)
          break
        end

        spans += inspection
        width += inspection_length
      end
      spans << RubyJard::Span.new(content: ']', styles: :text_secondary)

      spans
    end

    def decorate_multiline(variable, first_line_limit:, lines:, line_limit:)
      singleline = decorate_singleline(variable, line_limit: first_line_limit)
      if singleline.map(&:content_length).sum < line_limit || variable.length <= 1
        [singleline]
      else
        spans = [[RubyJard::Span.new(content: '[', styles: :text_secondary)]]

        item_count = 0
        variable.each_with_index do |item, index|
          spans << (
            [
              RubyJard::Span.new(content: '▸', margin_right: 1, margin_left: 2, styles: :text_dim)
            ] + @inspection_decorator.decorate_singleline(
              item, line_limit: line_limit - 4
            )
          )

          item_count += 1
          break if index >= lines - 2
        end

        spans << last_line(variable.length, item_count)
      end
    end

    def match?(variable)
      variable.is_a?(Array)
    end

    def last_line(total, item_count)
      if total > item_count
        [
          RubyJard::Span.new(
            content: "▸ #{total - item_count} more...",
            margin_left: 2, styles: :text_dim
          ),
          RubyJard::Span.new(
            content: ']',
            styles: :text_secondary
          )
        ]
      else
        [RubyJard::Span.new(content: ']', styles: :text_secondary)]
      end
    end
  end
end
