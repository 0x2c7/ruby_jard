# frozen_string_literal: true

module RubyJard
  class Column
    extend Forwardable

    attr_accessor :spans, :content_length, :width

    def initialize(spans: [])
      @spans = spans
      @width = 0
      @content_length = 0
    end
  end
end
