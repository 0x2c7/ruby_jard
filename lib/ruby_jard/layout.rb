# frozen_string_literal: true

module RubyJard
  ##
  # Data object to store calculated layout
  class Layout
    attr_accessor :template, :box_width, :box_height, :box_x, :box_y, :width, :height, :x, :y

    def initialize(template:, width: 0, height: 0, x: 0, y: 0, box_width:, box_height:, box_x:, box_y:)
      @template = template
      @box_width = box_width
      @box_height = box_height
      @box_x = box_x
      @box_y = box_y
      @width = width
      @height = height
      @x = x
      @y = y
    end
  end
end
