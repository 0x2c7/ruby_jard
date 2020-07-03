# frozen_string_literal: true

module RubyJard
  class Span
    extend Forwardable

    attr_accessor :span_template, :content, :content_length, :styles

    def_delegators :@span_template, :margin_left, :margin_right, :word_wrap, :ellipsis

    def initialize(span_template:, content: '', content_length: 0, styles: [])
      @span_template = span_template
      @content = content
      @content_length = content_length
      @styles = styles
    end
  end
end
