# frozen_string_literal: true

module RubyJard
  ##
  # Data object to store calculated layout
  class Layout
    attr_accessor :template, :parent_template,
                  :box_width, :box_height, :box_x, :box_y,
                  :width, :height, :x, :y

    def initialize(
      template: nil, parent_template: nil,
      width: 0, height: 0, x: 0, y: 0,
      box_width: 0, box_height: 0, box_x: 0, box_y: 0
    )
      @template = template
      @box_width = box_width
      @box_height = box_height
      @box_x = box_x
      @box_y = box_y
      @width = width
      @height = height
      @x = x
      @y = y
      @parent_template = parent_template
    end
  end
end
