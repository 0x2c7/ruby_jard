# frozen_string_literal: true

module RubyJard
  class HashDecorator
    def initialize(general_decorator)
      @general_decorator = general_decorator
    end

    def decorate(variable, multiline: true, inline_limit:, height:, width:)
      inline = decorate_inline(variable, inline_limit: inline_limit, height: height, width: width)
      if inline.map(&:content_length).sum < width
        [inline]
      elsif multiline
        decorate_multiline(variable, height: height, width: width)
      else
        [inline]
      end
    end

    private

    def decorate_multiline(variable, height:, width:)
      spans = [[RubyJard::Span.new(content: '{', styles: :text_dim)]]

      item_count = 0
      variable.each_with_index do |(key, value), index|
        line = []
        line << RubyJard::Span.new(content: '▸', margin_right: 1, margin_left: 2, styles: :text_dim)
        key_inspection = @general_decorator.decorate(
          key, multiline: false, height: height, width: width - 4, inline_limit: width - 4
        )
        line << key_inspection
        line << RubyJard::Span.new(content: '→', margin_right: 1, margin_left: 1, styles: :text_secondary)
        line << @general_decorator.decorate(
          value,
          multiline: false, height: height, width: width - 4,
          inline_limit: width - 6 - key_inspection.flatten.map(&:content_length).sum
        )
        spans << line.flatten
        item_count += 1
        break if index >= height - 2
      end
      if variable.length > item_count
        spans << [
          RubyJard::Span.new(
            content: "▸ #{variable.length - item_count} more...}",
            margin_left: 2, styles: :text_dim
          )
        ]
      end

      spans
    end

    def decorate_inline(variable, inline_limit:, height:, width:)
      spans = [RubyJard::Span.new(content: '{', styles: :text_dim)]
      content_width = 1
      variable.each_with_index do |(key, value), index|
        item_limit = [inline_limit / variable.length / 2, 30].max
        key_inspection = @general_decorator.decorate(
          key, multiline: false, height: height, width: width - 4, inline_limit: item_limit
        )
        value_inspection = @general_decorator.decorate(
          value, multiline: false, inline_limit: [item_limit - content_length(key_inspection), 30].max,
          height: height, width: width - 4
        )

        if content_width + content_length(key_inspection) + content_length(value_inspection) > inline_limit - 6
          spans << RubyJard::Span.new(content: '...', styles: :text_dim)
          break
        end
        spans << key_inspection
        content_width += content_length(key_inspection)

        spans << RubyJard::Span.new(content: '→', margin_left: 1, margin_right: 1, styles: :text_highlighted)
        content_width += 3

        spans << value_inspection
        content_width += content_length(value_inspection)

        if index < variable.length - 1
          spans << RubyJard::Span.new(content: ',', margin_right: 1, styles: :text_dim)
          width += 2
        end
      end
      spans << RubyJard::Span.new(content: '}', styles: :text_dim)
      spans.flatten
    end

    def content_length(inspection)
      inspection.flatten.map(&:content_length).sum
    end
  end
end
