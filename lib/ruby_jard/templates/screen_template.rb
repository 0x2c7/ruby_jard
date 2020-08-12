# frozen_string_literal: true

module RubyJard
  module Templates
    ##
    # Template of a screen. A screen doesn't have children. Each screen includes screen name, sizes androw template for
    # rendering.
    class ScreenTemplate
      attr_reader :screen, :row_template, :height_ratio, :width_ratio,
                  :min_width, :min_height,
                  :height, :width,
                  :adjust_mode

      def initialize(
        screen: nil,
        row_template: nil,
        height_ratio: nil, width_ratio: nil,
        min_width: nil, min_height: nil,
        height: nil, width: nil,
        adjust_mode: nil
      )
        @screen = screen
        @row_template = row_template
        @height_ratio = height_ratio
        @width_ratio = width_ratio
        @min_width = min_width
        @min_height = min_height
        @height = height
        @width = width
        @adjust_mode = adjust_mode
      end
    end
  end
end
