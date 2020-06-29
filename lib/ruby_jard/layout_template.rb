# frozen_string_literal: true

module RubyJard
  ##
  # Template of a layout. Templates are hierarchy. Each template includes the
  # sizing configuration, including absolute values, min, max, or ratio
  # relative to its parant.
  class LayoutTemplate
    attr_reader :screen, :height_ratio, :width_ratio,
                :min_width, :min_height,
                :height, :width,
                :children,
                :fill_width, :fill_height

    def initialize(
      screen: nil, height_ratio: nil, width_ratio: nil,
      min_width: nil, min_height: nil,
      height: nil, width: nil,
      children: [],
      fill_width: nil, fill_height: nil
    )
      @screen = screen
      @height_ratio = height_ratio
      @width_ratio = width_ratio
      @min_width = min_width
      @min_height = min_height
      @height = height
      @width = width
      @children = children
      @fill_width = fill_width
      @fill_height = fill_height
    end
  end

  WideLayoutTemplate = LayoutTemplate.new(
    min_width: 120,
    min_height: 10,
    fill_width: true,
    fill_height: false,
    children: [
      LayoutTemplate.new(
        height_ratio: 50,
        min_height: 7,
        fill_width: true,
        children: [
          LayoutTemplate.new(
            screen: :source,
            width_ratio: 60
          ),
          LayoutTemplate.new(
            width_ratio: 40,
            fill_height: true,
            children: [
              LayoutTemplate.new(
                screen: :variables,
                width_ratio: 100,
                height_ratio: 100,
                min_height: 3
              )
              # LayoutTemplate.new(
              #   screen: :breakpoints,
              #   width_ratio: 100,
              #   height_ratio: 25,
              #   min_height: 3
              # ),
              # LayoutTemplate.new(
              #   screen: :expressions,
              #   width_ratio: 100,
              #   height_ratio: 25,
              #   min_height: 3
              # )
            ]
          )
        ]
      ),
      LayoutTemplate.new(
        height_ratio: 20,
        min_height: 3,
        fill_width: true,
        children: [
          LayoutTemplate.new(
            screen: :backtrace,
            width_ratio: 60
          ),
          LayoutTemplate.new(
            screen: :threads,
            width_ratio: 40
          )
        ]
      ),
      LayoutTemplate.new(
        height: 2,
        screen: :menu
      )
    ]
  )

  DEFAULT_LAYOUT_TEMPLATES = [
    WideLayoutTemplate
  ].freeze
end
