# frozen_string_literal: true

module RubyJard
  class StringDecorator
    def initialize(general_decorator)
      @general_decorator = general_decorator
    end

    def decorate(variable, inline_limit:)
      str =
        if variable.length < inline_limit
          variable
        else
          variable[0..inline_limit - 2].inspect[1..-1].chomp!('"')[0..inline_limit - 3] + '»'
        end
      [
        [

          RubyJard::Span.new(content: '"', styles: :string),
          RubyJard::Span.new(content: str, styles: :string),
          RubyJard::Span.new(content: '"', styles: :string)
        ]
      ]
    end
  end
end
