# frozen_string_literal: true

module RubyJard
  ##
  # Data object to store calculated layout
  class Layout
    attr_accessor :template, :width, :height, :x, :y

    def initialize(template:, width: 0, height: 0, x: 0, y: 0)
      @template = template
      @width = width
      @height = height
      @x = x
      @y = y
    end
  end
end
