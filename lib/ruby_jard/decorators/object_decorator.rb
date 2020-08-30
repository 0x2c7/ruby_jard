# frozen_string_literal: true

module RubyJard
  ##
  # Default decorator for non-primitive data structure. It is aimed to replace default `inspect`.
  # If a variable re-implement `#inspect`, it hornors this decision, but still try to
  # parse the result.
  # Otherwise, it use `Kernel#to_s`, and try to push instance variables into the result.
  class ObjectDecorator
    DEFAULT_INSPECTION_PATTERN = /#<(.*:0x[0-9a-z]+)(.*)>/i.freeze

    def initialize(general_decorator)
      @general_decorator = general_decorator
      @attributes_decorator = RubyJard::Decorators::AttributesDecorator.new(general_decorator)
    end

    def decorate_singleline(variable, line_limit:)
      if native_inspect?(variable)
        decorate_native_inspection(variable, line_limit: line_limit)
      else
        decorate_custom_inspection(variable, line_limit: line_limit)
      end
    end

    def decorate_multiline(variable, first_line_limit:, lines:, line_limit:)
      singleline = decorate_singleline(variable, line_limit: first_line_limit)
      return [singleline] if singleline.map(&:content_length).sum < line_limit

      spans = [excerpt(variable.to_s, line_limit: first_line_limit)]

      return spans if !variable.respond_to?(:instance_variables) ||
                      !variable.respond_to?(:instance_variable_get)

      item_count = 0
      variable.instance_variables.each do |instance_variable|
        spans << @attributes_decorator.pair(
          instance_variable, variable.instance_variable_get(instance_variable),
          line_limit: line_limit, process_key: false
        )

        item_count += 1
        break if item_count >= lines - 2
      end

      if variable.instance_variables.length > item_count
        spans << [
          RubyJard::Span.new(
            content: "▸ #{variable.instance_variables.length - item_count} more...",
            margin_left: 2, styles: :text_dim
          )
        ]
      end

      spans
    end

    private

    def native_inspect?(variable)
      Kernel.method(:method).unbind.bind(variable).call(:inspect).owner == ::Kernel
    end

    def decorate_native_inspection(variable, line_limit:)
      raw_inspection = variable.to_s
      match = raw_inspection.match(DEFAULT_INSPECTION_PATTERN)

      if match
        padding = variable.instance_variables.empty? ? 0 : 1
        spans = [
          RubyJard::Span.new(content: '#<', styles: :text_secondary),
          RubyJard::Span.new(content: match[1], margin_right: padding, styles: :text_secondary)
        ]
        spans += @attributes_decorator.inline_pairs(
          variable.instance_variables.each_with_index, total: variable.instance_variables.length,
          line_limit: line_limit - spans.map(&:content_length).sum - 1,
          process_key: false, value_proc: ->(key) { variable.instance_variable_get(key) }
        )
        spans << RubyJard::Span.new(content: '>', styles: :text_secondary)
        spans
      elsif raw_inspection.length <= line_limit
        [
          RubyJard::Span.new(
            content: raw_inspection[0..line_limit],
            styles: :text_secondary
          )
        ]
      else
        [
          RubyJard::Span.new(
            content: raw_inspection[0..line_limit - 3] + '…>',
            styles: :text_secondary
          )
        ]
      end
    end

    def decorate_custom_inspection(variable, line_limit:)
      excerpt(variable.inspect, line_limit: line_limit)
    end

    def excerpt(raw_inspection, line_limit:)
      match = raw_inspection.match(DEFAULT_INSPECTION_PATTERN)
      if match
        detail =
          if match[2].length < line_limit - match[1].length - 3
            match[2]
          else
            match[2][0..line_limit - match[1].length - 4] + '…'
          end
        [
          RubyJard::Span.new(content: '#<', styles: :text_secondary),
          RubyJard::Span.new(content: match[1], styles: :text_secondary),
          RubyJard::Span.new(content: detail, styles: :text_dim),
          RubyJard::Span.new(content: '>', styles: :text_secondary)
        ]
      elsif raw_inspection.length <= line_limit
        [
          RubyJard::Span.new(
            content: raw_inspection[0..line_limit],
            styles: :text_secondary
          )
        ]
      else
        [
          RubyJard::Span.new(
            content: raw_inspection[0..line_limit - 3] + '…>',
            styles: :text_secondary
          )
        ]
      end
    end
  end
end
