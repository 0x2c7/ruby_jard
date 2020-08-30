# frozen_string_literal: true

module RubyJard
  class ObjectDecorator
    RAW_INSPECTION_PATTERN = /#<(.*)(:0x[0-9]+.*)>/i.freeze

    def initialize(general_decorator)
      @general_decorator = general_decorator
      @attributes_decorator = RubyJard::Decorators::AttributesDecorator.new(general_decorator)
    end

    def decorate_singleline(variable, line_limit:)
      raw_inspection = inspect_object(variable)
      match = raw_inspection.match(RAW_INSPECTION_PATTERN)
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
          RubyJard::Span.new(content: detail, styles: :text_secondary),
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

    def decorate_multiline(variable, first_line_limit:, lines:, line_limit:)
      spans = [decorate_singleline(variable, line_limit: first_line_limit)]

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

    def inspect_object(variable)
      if Kernel.method(:method).unbind.bind(variable).call(:inspect).owner == ::Kernel
        variable.to_s
      else
        # Respect custom inspect implementation
        variable.inspect
      end
    end
  end
end
