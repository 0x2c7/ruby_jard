# frozen_string_literal: true

module RubyJard
  class ArrayDecorator
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
      spans = [[RubyJard::Span.new(content: '[', styles: :text_dim)]]

      item_count = 0
      variable.each_with_index do |item, index|
        spans << [
          RubyJard::Span.new(content: '▸', margin_right: 1, margin_left: 2, styles: :text_dim),
          @general_decorator.decorate(
            item, multiline: false, height: height, width: width - 4, inline_limit: width - 4
          )
        ].flatten
        item_count += 1
        break if index >= height - 2
      end
      if variable.length > item_count
        spans << [
          RubyJard::Span.new(
            content: "▸ #{variable.length - item_count} more...]",
            margin_left: 2, styles: :text_dim
          )
        ]
      end

      spans
    end

    def decorate_inline(variable, inline_limit:, height:, width:)
      spans = [RubyJard::Span.new(content: '[', styles: :text_dim)]
      current_width = 1
      variable.each_with_index do |item, index|
        item_limit = [inline_limit / variable.length, 30].max
        inspection = @general_decorator.decorate(
          item, multiline: false, inline_limit: item_limit, height: height, width: width
        )
        if current_width + inspection.flatten.map(&:content_length).sum > inline_limit - 3
          spans << RubyJard::Span.new(content: '...', styles: :text_dim)
          break
        end
        spans << inspection
        current_width += inspection.flatten.map(&:content_length).sum
        if index < variable.length - 1
          spans << RubyJard::Span.new(content: ',', margin_right: 1, styles: :text_dim)
          current_width += 2
        end
      end
      spans << RubyJard::Span.new(content: ']', styles: :text_dim)
      spans.flatten
    end
  end
end
