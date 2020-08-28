# frozen_string_literal: true

module RubyJard
  class StructDecorator
    def initialize(general_decorator)
      @general_decorator = general_decorator
    end

    def match?(variable)
      variable.is_a?(Struct)
    end

    def decorate_singleline(variable, line_limit:)
      spans = struct_label_spans(variable)

      width = 1
      variable.members.each_with_index do |member, index|
        item_limit = [line_limit / variable.length / 2, 30].max
        member_label = member.to_s

        value_inspection = @general_decorator.decorate_singleline(
          variable[member], line_limit: [item_limit - member_label.length, 30].max
        )
        value_inspection_length = value_inspection.map(&:content_length).sum

        if index > 0
          spans << RubyJard::Span.new(content: ',', margin_right: 1, styles: :text_secondary)
          width += 2
        end

        if width + member_label.length + value_inspection_length + 3 > line_limit
          spans << RubyJard::Span.new(content: '…', styles: :text_dim)
          break
        end

        spans << RubyJard::Span.new(content: member_label, margin_right: 1, styles: :text_secondary)
        width += member_label.length

        spans << RubyJard::Span.new(content: '→', margin_right: 1, styles: :text_highlighted)
        width += 3

        spans << value_inspection
        width += value_inspection_length
      end

      spans << RubyJard::Span.new(content: '>', styles: :text_secondary)
      spans
    end

    def decorate_multiline(variable, first_line_limit:, lines:, line_limit:)
      singleline = decorate_singleline(variable, line_limit: first_line_limit)

      if singleline.map(&:content_length).sum < line_limit || variable.length <= 1
        [singleline]
      else
        spans = [struct_label_spans(variable)]

        item_count = 0
        variable.members.each_with_index do |member, index|
          line = []
          member_label = member.to_s
          line << RubyJard::Span.new(content: '▸', margin_right: 1, margin_left: 2, styles: :text_dim)
          line << RubyJard::Span.new(content: member_label, margin_right: 1, styles: :text_secondary)
          line << RubyJard::Span.new(content: '→', margin_right: 1, margin_left: 1, styles: :text_highlighted)
          line += @general_decorator.decorate_singleline(
            variable[member], line_limit: line_limit - 4 - member_label.length
          )

          spans << line
          item_count += 1
          break if index >= lines - 2
        end
        spans << last_line(variable.length, item_count)
      end
    end

    private

    def struct_label_spans(variable)
      spans = [RubyJard::Span.new(content: '#<struct ', styles: :text_secondary)]
      unless variable.class.name.nil?
        spans << RubyJard::Span.new(content: variable.class.name.to_s, styles: :text_dim)
      end
      spans
    end

    def last_line(total, item_count)
      if total > item_count
        [
          RubyJard::Span.new(
            content: "▸ #{total - item_count} more...",
            margin_left: 2, styles: :text_dim
          ),
          RubyJard::Span.new(
            content: '>',
            styles: :text_secondary
          )
        ]
      else
        [RubyJard::Span.new(content: '>', styles: :text_secondary)]
      end
    end
  end
end
