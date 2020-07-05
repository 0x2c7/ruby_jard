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

    def initialize(output:, screens:)
      @output = output
      @screens = screens
    end

    def draw
      draw_basic_lines
      corners = calculate_corners
      draw_corners(corners)
    end

    private

    def draw_basic_lines
      # Exclude the corners
      @screens.each do |_template, width, height, x, y|
        @output.print TTY::Cursor.move_to(x + 1, y)
        @output.print HORIZONTAL_LINE * (width - 2)

        @output.print TTY::Cursor.move_to(x + 1, y + height - 1)
        @output.print HORIZONTAL_LINE * (width - 2)

        (y + 1..y + height - 2).each do |moving_y|
          @output.print TTY::Cursor.move_to(x, moving_y)
          @output.print VERTICAL_LINE
          @output.print TTY::Cursor.move_to(x + width - 1, moving_y)
          @output.print VERTICAL_LINE
        end
      end
    end

    def draw_corners(corners)
      corners.each do |x, corners_x|
        corners_x.each do |y, ids|
          @output.print TTY::Cursor.move_to(x, y)

          case ids.length
          when 1
            @output.print NORMALS_CORNERS[ids.first]
          when 2
            ids = ids.sort
            @output.print OVERLAPPED_CORNERS[ids]
          else
            @output.print CROSS_CORNER
          end
        end
      end
    end

    def calculate_corners
      corners = {}
      @screens.each do |_template, width, height, x, y|
        mark_corner(corners, x, y, TOP_LEFT)
        mark_corner(corners, x + width - 1, y, TOP_RIGHT)
        mark_corner(corners, x + width - 1, y + height - 1, BOTTOM_RIGHT)
        mark_corner(corners, x, y + height - 1, BOTTOM_LEFT)
      end
      corners
    end

    def mark_corner(corners, x, y, id)
      corners[x] ||= {}
      corners[x][y] ||= []
      corners[x][y] << id unless corners[x][y].include?(id)
    end
  end
end
