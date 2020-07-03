# frozen_string_literal: true

module RubyJard
  ##
  # Draw a screen and its rows into the output interface.
  class ScreenDrawer
    attr_reader :output

    def initialize(output:)
      @output = output
      @color_decorator = Pastel.new
    end

    def draw(screen, pos_x, pos_y)
      draw_box(screen, pos_x, pos_y)
      draw_rows(screen, pos_x, pos_y)
    end

    private

    def draw_box(screen, pos_x, pos_y)
      frame_styles = default_frame_styles.merge(
        top: pos_y - 1, left: pos_x - 1, width: screen.width + 1, height: screen.height + 1
      )
      @output.print TTY::Box.frame(**frame_styles)
      @output.print TTY::Cursor.move_to(pos_x + 2, pos_y - 1)
      @output.print @color_decorator.decorate(screen.title, :bright_yellow)
    end

    def draw_rows(screen, pos_x, pos_y)
      position = {
        x: pos_x + 1,
        y: pos_y
      }
      screen.rows.each do |row|
        position[:x] = pos_x
        draw_columns(position, row.columns)
        position[:y] += 1
      end
    end

    def draw_columns(position, columns)
      columns.each do |column|
        width = 0
        column_content_width = column.width - column.margin_left - column.margin_right
        position[:x] += column.margin_left
        @output.print TTY::Cursor.move_to(position[:x], position[:y])

        column.spans.each do |span|
          line_content = span.content

          until line_content.empty?
            if width + line_content.length > column_content_width
              @output.print @color_decorator.decorate(line_content[0..column_content_width - width - 1], *span.styles)

              line_content = line_content[column_content_width - width..-1]
              width = 0
              position[:y] += 1

              @output.print TTY::Cursor.move_to(position[:x], position[:y])
            else
              @output.print @color_decorator.decorate(line_content, *span.styles)
              width += line_content.length
              break
            end
          end
        end
        position[:x] += column_content_width + column.margin_right
      end
    end

    def default_frame_styles
      {
        style: {
          fg: :white
        },
        border: {
          bottom_left: false,
          bottom_right: false,
          bottom: false,
          left: :line,
          right: false
        }
      }
    end
  end
end
