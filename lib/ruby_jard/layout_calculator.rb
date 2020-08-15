# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
module RubyJard
  ##
  # Layout calculator based on screen resolution to decide the height, width,
  # visibility, data size of each children screen.
  # TODO: Right now, the sizes are fixed regardless of current screen data size.
  class LayoutCalculator
    def self.calculate(**args)
      new(**args).calculate
    end

    def initialize(
      layout_template:, width: 0, height: 0, x: 0, y: 0,
      config: RubyJard.config
    )
      @layout_template = layout_template
      @width = width
      @height = height
      @x = x
      @y = y
      @layouts = []
      @config = config
    end

    def calculate
      @layouts = []
      calculate_layout(@layout_template, @width, @height, @x, @y, nil)
      @layouts
    end

    private

    def calculate_layout(template, width, height, x, y, parent_template)
      if template.is_a?(RubyJard::Templates::ScreenTemplate)
        layout = RubyJard::Layout.new(
          template: template, parent_template: parent_template,
          width: width - 2, height: height - 2, x: x + 1, y: y + 1,
          box_width: width, box_height: height, box_x: x, box_y: y
        )
        adjust_layout_overlap(layout)
        @layouts << layout
      else
        overflow_width = 0
        child_x = x
        child_y = y
        max_height = 0

        lines = [[]]
        visible_children(template).each do |child_template|
          child_height = calculate_child_height(child_template, height)
          child_width = calculate_child_width(child_template, width)

          overflow_width += child_width
          # Overflow. Break to next line
          if overflow_width > width
            child_y += max_height
            child_x = x
            overflow_width = 0
            max_height = child_height
            lines << []
          elsif max_height < child_height
            max_height = child_height
          end

          lines.last << [child_template, child_width, child_height, child_x, child_y]
          child_x += child_width
        end

        stretch_children_layouts(template, width, height, lines)
        lines.each do |line|
          line.each do |child_template, child_width, child_height, xx, yy|
            calculate_layout(child_template, child_width, child_height, xx, yy, template)
          end
        end
      end
    end

    def visible_children(template)
      template.children.select do |child|
        visible?(child)
      end
    end

    def visible?(template)
      if template.is_a?(RubyJard::Templates::ScreenTemplate)
        @config.enabled_screens.include?(template.screen.to_s.strip)
      else
        template.children.any? { |child| visible?(child) }
      end
    end

    def adjust_layout_overlap(layout)
      if layout.box_x != 0
        layout.width += 1
        layout.x -= 1
        layout.box_width += 1
        layout.box_x -= 1
      end

      if layout.box_y != 0
        layout.height += 1
        layout.y -= 1
        layout.box_height += 1
        layout.box_y -= 1
      end
    end

    # Stretch the children layouts to fill the gaps, remove redundant spaces inside the parent layout
    def stretch_children_layouts(parent_template, parent_width, parent_height, lines)
      total_height = 0
      lines.each_with_index do |line, line_index|
        desired_height =
          if line_index == lines.length - 1
            parent_height - total_height
          else
            line.map { |_child_template, _child_width, child_height, _x, _y| child_height }.max
          end

        total_width = 0
        line.map!.with_index do |(child_template, child_width, child_height, x, y), index|
          child_height = desired_height if parent_template.fill_height
          child_width = parent_width - total_width if parent_template.fill_width && index == line.length - 1
          total_width += child_width
          [child_template, child_width, child_height, x, y]
        end
        total_height += desired_height
      end
    end

    def calculate_child_height(child_template, parent_height)
      height =
        if !child_template.height.nil?
          child_template.height
        elsif child_template.height_ratio.nil?
          parent_height
        else
          parent_height * child_template.height_ratio / 100
        end

      unless child_template.min_height.nil?
        height = child_template.min_height if height < child_template.min_height
      end

      height
    end

    def calculate_child_width(child_template, parent_width)
      width =
        if !child_template.width.nil?
          child_template.width
        elsif child_template.width_ratio.nil?
          parent_width
        else
          parent_width * child_template.width_ratio / 100
        end

      unless child_template.min_width.nil?
        width = child_template.min_width if width < child_template.min_width
      end

      width
    end
  end
end

# rubocop:enable Metrics/MethodLength
