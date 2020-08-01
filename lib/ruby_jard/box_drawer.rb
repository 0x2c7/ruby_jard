# frozen_string_literal: true

module RubyJard
  ##
  # Drawer to draw a nice single-line box that maximize screen area
  #
  # Each screen has 4 corners and clock-wise corresponding ID:
  # - Top-left => 1
  # - Top-right => 2
  # - Bottom-right => 3
  # - Bottom-left => 4
  #
  # For each screen, add each point to a coordinator hash.
  # - If a point is occupied by 1 screen, draw normal box corner symbol.
  # - If a point is occupied by 2 screens, look up in a map, and draw corresponding intersection corner symbol.
  # - If a point is occupied by 3 or more screens, it's definitely a + symbol.
  #
  # The corner list at each point (x, y) is unique. If 2 screens overlap a point with same corner ID, it means
  # 2 screens overlap, and have same corner symbol.
  class BoxDrawer
    CORNERS = [
      TOP_LEFT = 1,
      TOP_RIGHT = 2,
      BOTTOM_RIGHT = 3,
      BOTTOM_LEFT = 4
    ].freeze

    HORIZONTAL_LINE = '─'
    VERTICAL_LINE = '│'
    CROSS_CORNER = '┼'

    NORMALS_CORNERS = {
      TOP_LEFT => '┌',
      TOP_RIGHT => '┐',
      BOTTOM_RIGHT => '┘',
      BOTTOM_LEFT => '└'
    }.freeze

    OVERLAPPED_CORNERS = {
      [TOP_LEFT, TOP_RIGHT] => '┬',
      [TOP_LEFT, BOTTOM_RIGHT] => '┼',
      [TOP_LEFT, BOTTOM_LEFT] => '├',
      [TOP_RIGHT, BOTTOM_RIGHT] => '┤',
      [TOP_RIGHT, BOTTOM_LEFT] => '┼',
      [BOTTOM_RIGHT, BOTTOM_LEFT] => '┴'
    }.freeze

    def initialize(output:, screens:, color_scheme:)
      @output = output
      @screens = screens
      @color_decorator = RubyJard::Decorators::ColorDecorator.new(color_scheme)
    end

    def draw
      draw_basic_lines
      corners = calculate_corners
      draw_corners(corners)
      draw_titles
    end

    private

    def draw_basic_lines
      # Exclude the corners
      @screens.each do |screen|
        RubyJard::Console.move_to(
          @output,
          screen.layout.box_x + 1,
          screen.layout.box_y
        )
        @output.print colorize_border(HORIZONTAL_LINE * (screen.layout.box_width - 2))

        RubyJard::Console.move_to(
          @output,
          screen.layout.box_x + 1,
          screen.layout.box_y + screen.layout.box_height - 1
        )
        @output.print colorize_border(HORIZONTAL_LINE * (screen.layout.box_width - 2))

        (screen.layout.box_y + 1..screen.layout.box_y + screen.layout.box_height - 2).each do |moving_y|
          RubyJard::Console.move_to(@output, screen.layout.box_x, moving_y)
          @output.print colorize_border(VERTICAL_LINE)

          RubyJard::Console.move_to(@output, screen.layout.box_x + screen.layout.box_width - 1, moving_y)
          @output.print colorize_border(VERTICAL_LINE)
        end
      end
    end

    def draw_corners(corners)
      corners.each do |x, corners_x|
        corners_x.each do |y, ids|
          RubyJard::Console.move_to(@output, x, y)

          case ids.length
          when 1
            @output.print colorize_border(NORMALS_CORNERS[ids.first])
          when 2
            ids = ids.sort
            @output.print colorize_border(OVERLAPPED_CORNERS[ids])
          else
            @output.print colorize_border(CROSS_CORNER)
          end
        end
      end
    end

    def draw_titles
      @screens.each do |screen|
        next unless screen.respond_to?(:title)

        RubyJard::Console.move_to(@output, screen.layout.box_x + 1, screen.layout.box_y)
        total_length = 0
        title_parts = Array(screen.title)
        title_parts.each_with_index do |title_part, index|
          if index == 0
            @output.print @color_decorator.decorate(:title, " #{title_part} ")
          else
            @output.print @color_decorator.decorate(:title_secondary, " #{title_part} ")
          end
          total_length += title_part.length + 2
        end
        title_background = screen.layout.box_width - total_length - 2
        @output.print @color_decorator.decorate(
          :title_background,
          HORIZONTAL_LINE * (title_background < 0 ? 0 : title_background)
        )
      end
    end

    def calculate_corners
      corners = {}
      @screens.each do |screen|
        mark_corner(
          corners,
          screen.layout.box_x,
          screen.layout.box_y,
          TOP_LEFT
        )
        mark_corner(
          corners,
          screen.layout.box_x + screen.layout.box_width - 1,
          screen.layout.box_y,
          TOP_RIGHT
        )
        mark_corner(
          corners,
          screen.layout.box_x + screen.layout.box_width - 1,
          screen.layout.box_y + screen.layout.box_height - 1,
          BOTTOM_RIGHT
        )
        mark_corner(
          corners,
          screen.layout.box_x,
          screen.layout.box_y + screen.layout.box_height - 1,
          BOTTOM_LEFT
        )
      end
      corners
    end

    def mark_corner(corners, x, y, id)
      corners[x] ||= {}
      corners[x][y] ||= []
      corners[x][y] << id unless corners[x][y].include?(id)
    end

    def colorize_border(content)
      @color_decorator.decorate(:border, content)
    end
  end
end
