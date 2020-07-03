# frozen_string_literal: true

module RubyJard
  ##
  # Draw a screen and its rows into the output interface.
  class ScreenDrawer
    attr_reader :output

    ELLIPSIS = ' [...]'

    def initialize(output:, screen:, x:, y:)
      @output = output
      @color_decorator = Pastel.new
      @pos_x = x
      @pos_y = y
      @original_pos_x = x
      @original_pos_y = y
      @screen = screen
    end

    def draw
      draw_box
      draw_rows
    end

    private

    def draw_box
      frame_styles = default_frame_styles.merge(
        top: @pos_y - 1, left: @pos_x - 1, width: @screen.width + 1, height: @screen.height + 1
      )
      @output.print TTY::Box.frame(**frame_styles)
      @output.print TTY::Cursor.move_to(@pos_x + 2, @pos_y - 1)
      @output.print ' '
      @output.print @color_decorator.decorate(@screen.title, :bright_yellow)
      @output.print ' '
    end

    def draw_rows
      @original_pos_x = @pos_x
      @screen.rows.each do |row|
        draw_columns(row, row.columns)
        @pos_y += 1
        @pos_x = @original_pos_x
      end
    end

    def draw_columns(row, columns)
      columns.each do |column|
        width = 0
        column_content_width = column.width - column.margin_left - column.margin_right
        @pos_x += column.margin_left
        @output.print TTY::Cursor.move_to(@pos_x, @pos_y)

        column.spans.each do |span|
          line_content = span.content
          lines = 1

          until line_content.empty?
            if width + line_content.length > column_content_width
              protected_print @color_decorator.decorate(
                line_content[0..column_content_width - width - 1],
                *span.styles
              )
              line_content = line_content[column_content_width - width..-1]
              width = 0
              lines += 1
              if !row.line_limit.nil? && lines > row.line_limit
                @output.print TTY::Cursor.move_to(@pos_x + column.width - ELLIPSIS.length, @pos_y)
                protected_print @color_decorator.decorate(ELLIPSIS, *span.styles)
                break
              end

              @pos_y += 1
              @output.print TTY::Cursor.move_to(@pos_x, @pos_y)
            else
              protected_print @color_decorator.decorate(line_content, *span.styles)
              width += line_content.length
              break
            end
          end
        end
        @pos_x += column_content_width + column.margin_right
      end
    end

    def protected_print(content)
      # TODO: currently, only row overflow is detected. Definitely should handle column overflow
      return if @pos_y < @original_pos_y || @pos_y > @original_pos_y + @screen.height - 1

      @output.print content
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
