# frozen_string_literal: true

module RubyJard
  class Span
    extend Forwardable

    attr_accessor :span_template, :content, :content_length, :styles

    def_delegators :@span_template, :margin_left, :margin_right, :word_wrap, :ellipsis

    def initialize(span_template:)
      @span_template = span_template
      @content = ''
      @content_length = 0
      @styles = []
    end
  end
end
