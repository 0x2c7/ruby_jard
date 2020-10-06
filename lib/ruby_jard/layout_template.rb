# frozen_string_literal: true

module RubyJard
  ##
  # Template of a layout. Templates are hierarchy. Each template includes the
  # sizing configuration, including absolute values, min, max, or ratio
  # relative to its parant.
  class LayoutTemplate
    attr_reader :height_ratio, :width_ratio,
                :min_width, :min_height,
                :height, :width,
                :children,
                :fill_width, :fill_height

    def initialize(
      *children,
      height_ratio: nil, width_ratio: nil,
      min_width: nil, min_height: nil,
      height: nil, width: nil,
      fill_width: true, fill_height: true
    )
      @children = children
      @height_ratio = height_ratio
      @width_ratio = width_ratio
      @min_width = min_width
      @min_height = min_height
      @height = height
      @width = width
      @fill_width = fill_width
      @fill_height = fill_height
    end
  end
end
