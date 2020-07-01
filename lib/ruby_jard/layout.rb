# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/CyclomaticComplexity
module RubyJard
  ##
  # Layout calculator based on screen resolution to decide the height, width,
  # visibility, data size of each children screen.
  # TODO: Right now, the sizes are fixed regardless of current screen data size.
  class Layout
    def self.calculate(**args)
      new(**args).calculate
    end

    def initialize(layout:, width: 0, height: 0, row: 0, col: 0)
      @layout = layout
      @width = width
      @height = height
      @row = row
      @col = col
    end

    def calculate
      screens = []
      calculate_layout(screens, @layout, @width, @height, @row, @col)
      screens
    end

    private

    def calculate_layout(screens, layout, width, height, row, col)
      if layout.is_a?(RubyJard::Templates::ScreenTemplate)
        screens << [layout, width, height, row, col]
      else
        total_height = 0
        total_width = 0
        overflow_width = 0
        child_row = row
        child_col = col
        max_height = 0

        layout.children.each_with_index do |child_layout, index|
          child_height = calculate_child_height(child_layout, layout, height, index, total_height)
          child_width = calculate_child_width(child_layout, layout, width, index, total_width)

          calculate_layout(screens, child_layout, child_width, child_height, child_row, child_col)

          overflow_width += child_width
          max_height = child_height if max_height < child_height
          # Overflow. Break to next line
          if overflow_width >= width
            child_row += max_height
            child_col = col
            overflow_width = 0
            max_height = 0
          else
            child_col += child_width
          end

          total_width += child_width
          total_height += child_height
        end
      end
    end

    def calculate_child_height(child_layout, parent_layout, parent_height, index, total_height)
      height =
        if !child_layout.height.nil?
          child_layout.height
        elsif child_layout.height_ratio.nil?
          parent_height
        else
          parent_height * child_layout.height_ratio / 100
        end

      unless child_layout.min_height.nil?
        height = child_layout.min_height if height < child_layout.min_height
      end

      if parent_layout.fill_height && index == parent_layout.children.length - 1
        height = parent_height - total_height if height < (parent_height - total_height)
      end

      height
    end

    def calculate_child_width(child_layout, parent_layout, parent_width, index, total_width)
      width =
        if !child_layout.width.nil?
          child_layout.width
        elsif child_layout.width_ratio.nil?
          parent_width
        else
          parent_width * child_layout.width_ratio / 100
        end

      unless child_layout.min_width.nil?
        width = child_layout.min_width if width < child_layout.min_width
      end

      if parent_layout.fill_width && index == parent_layout.children.length - 1
        width = parent_width - total_width if width < (parent_width - total_width)
      end

      width
    end
  end
end

# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/CyclomaticComplexity

