# frozen_string_literal: true

module RubyJard
  class ObjectDecorator
    OBJECT_ADDRESS_PATTERN = /#<(.*)(:0x[0-9]+.*)>/i.freeze

    def initialize(general_decorator)
      @general_decorator = general_decorator
    end

    def decorate(variable, multiline: true, inline_limit:, height:, width:)
      spans = [object_address(variable, multiline: multiline, inline_limit: inline_limit)]

      if multiline
        item_count = 0
        variable.instance_variables.each do |instance_variable|
          spans << [
            RubyJard::Span.new(content: '▸', margin_right: 1, margin_left: 2, styles: :text_dim),
            RubyJard::Span.new(content: instance_variable.to_s, margin_right: 1, styles: :text_secondary),
            RubyJard::Span.new(content: '=', margin_right: 1, margin_left: 1, styles: :text_secondary),
            @general_decorator.decorate(
              variable.instance_variable_get(instance_variable),
              multiline: false, inline_limit: width - instance_variable.to_s.length - 6,
              height: height, width: width - 4
            )
          ].flatten

          item_count += 1
          break if item_count > height - 3
        end

        if variable.instance_variables.length > item_count
          spans << [
            RubyJard::Span.new(
              content: "▸ #{variable.instance_variables.length - item_count} more...",
              margin_left: 2, styles: :text_dim
            )
          ]
        end
      end
      spans
    end

    private

    def object_address(variable, multiline:, inline_limit:)
      object_address = variable.to_s
      match = object_address.match(OBJECT_ADDRESS_PATTERN)
      if match
        overview = match[1]
        detail =
          if match[2].length < inline_limit - overview.length - 3
            match[2]
          else
            match[2][0..inline_limit - overview.length - 6] + '...'
          end
        style = multiline ? :text_secondary : :text_dim
        [
          RubyJard::Span.new(
            content: '#<',
            styles: style
          ),
          RubyJard::Span.new(
            content: overview,
            styles: style
          ),
          RubyJard::Span.new(
            content: detail,
            styles: style
          ),
          RubyJard::Span.new(
            content: '>',
            styles: style
          )
        ]
      elsif object_address.length <= inline_limit
        [
          RubyJard::Span.new(
            content: object_address[0..inline_limit],
            styles: :text_secondary
          )
        ]
      else
        [
          RubyJard::Span.new(
            content: object_address[0..inline_limit - 3] + '...',
            styles: :text_secondary
          )
        ]
      end
    end
  end
end
