# frozen_string_literal: true

module RubyJard
  ##
  # Layout calculator based on screen resolution to decide the height, width,
  # visibility, data size of each children screen.
  # TODO: Right now, the sizes are fixed regardless of current screen data size.
  class Layout
    def self.generate(**args)
      layout = new(**args)
      layout.generate
      layout
    end

    attr_accessor :width, :height, :screen, :children

    def initialize(template:, width: 0, height: 0)
      @template = template
      @width = width
      @height = height
      @screen = nil
      @children = []
    end

    def generate
      if @template.screen.nil? && !@template.children.empty?
        generate_childen
      else
        # Ignore children if a layout is a screen
        @screen = @template.screen
      end

      self
    end

    private

    def generate_childen
      total_height = 0
      total_width = 0

      @children = @template.children.map.with_index do |child_template, index|
        child = RubyJard::Layout.new(
          template: child_template,
          height: calculate_child_height(child_template, index, total_height),
          width: calculate_child_width(child_template, index, total_width)
        )
        child.generate

        total_width += child.width
        total_height += child.height

        child
      end
    end

    def calculate_child_height(child_template, index, total_height)
      height =
        if !child_template.height.nil?
          child_template.height
        elsif child_template.height_ratio.nil?
          @height
        else
          @height * child_template.height_ratio / 100
        end

      unless child_template.min_height.nil?
        height = child_template.min_height if height < child_template.min_height
      end

      if @template.fill_height && index == @template.children.length - 1
        height = @height - total_height if height < (@height - total_height)
      end

      height
    end

    def calculate_child_width(child_template, index, total_width)
      width =
        if !child_template.width.nil?
          child_template.width
        elsif child_template.width_ratio.nil?
          @width
        else
          @width * child_template.width_ratio / 100
        end

      unless child_template.min_width.nil?
        width = child_template.min_width if width < child_template.min_width
      end

      if @template.fill_width && index == @template.children.length - 1
        width = @width - total_width if width < (@width - total_width)
      end

      width
    end
  end
end
