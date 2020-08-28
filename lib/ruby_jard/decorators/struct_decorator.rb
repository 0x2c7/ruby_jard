# frozen_string_literal: true

module RubyJard
  class StructDecorator
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
      variable.members.each_with_index do |member, index|
        line = []
        line << RubyJard::Span.new(content: '▸', margin_right: 1, margin_left: 2, styles: :text_dim)
        line << RubyJard::Span.new(content: member.to_s, margin_right: 1, styles: :text_secondary)
        line << RubyJard::Span.new(content: '→', margin_right: 1, styles: :text_secondary)
        line << @general_decorator.decorate(
          variable[member],
          multiline: false, height: height, width: width - 4,
          inline_limit: width - 6 - member.to_s.length
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
      spans = [RubyJard::Span.new(content: '#<struct ', styles: :text_dim)]
      unless variable.class.name.nil?
        spans << RubyJard::Span.new(content: variable.class.name.to_s, styles: :text_dim)
      end
      content_width = 1
      variable.members.each_with_index do |member, index|
        item_limit = [inline_limit / variable.length / 2, 30].max
        value_inspection = @general_decorator.decorate(
          variable[member], multiline: false, inline_limit: [item_limit - member.to_s.length, 30].max,
          height: height, width: width - 4
        )

        if content_width + member.to_s.length + content_length(value_inspection) > inline_limit - 6
          spans << RubyJard::Span.new(content: '...', styles: :text_dim)
          break
        end
        spans << RubyJard::Span.new(content: member.to_s, margin_right: 1, styles: :text_secondary)
        content_width += member.to_s.length

        spans << RubyJard::Span.new(content: '→', margin_right: 1, styles: :text_highlighted)
        content_width += 3

        spans << value_inspection
        content_width += content_length(value_inspection)

        if index < variable.length - 1
          spans << RubyJard::Span.new(content: ',', margin_right: 1, styles: :text_dim)
          width += 2
        end
      end
      spans << RubyJard::Span.new(content: '>', styles: :text_dim)
      spans.flatten
    end

    def content_length(inspection)
      inspection.flatten.map(&:content_length).sum
    end
  end
end
