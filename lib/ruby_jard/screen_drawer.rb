# frozen_string_literal: true

module RubyJard
  ##
  # Draw a screen and its rows into the output interface.
  class ScreenDrawer
    attr_reader :output

    ELLIPSIS = ' »'

    def initialize(output:, screen:)
      @output = output
      @color_decorator = RubyJard::Decorators::ColorDecorator.new(screen.color_scheme)
      @width = screen.width
      @height = screen.height
      @x = screen.x
      @y = screen.y
      @original_x = screen.x
      @original_y = screen.y
      @rows = screen.rows
    end

    def draw
      (@y..@y + @height - 1).each do |y|
        RubyJard::Console.move_to(@output, @x, y)
        # RubyJard.debug("x = #{@x}, y = #{y}, width = #{@width}")
        @output.print @color_decorator.decorate_element(:background, ' ' * @width)
      end

      @original_x = @x
      @rows.each do |row|
        draw_columns(row, row.columns)
        @y += 1
        @x = @original_x
      end
    end

    private

    def draw_columns(row, columns)
      columns.each do |column|
        width = 0
        lines = 1
        column_content_width = column.width - column.margin_left - column.margin_right
        @x += column.margin_left
        RubyJard::Console.move_to(@output, @x, @y)

        column.spans.each do |span|
          line_content = span.content

          until line_content.nil? || line_content.empty?
            if column_content_width - width <= 0
              width = 0
              lines += 1
              @y += 1
              RubyJard::Console.move_to(@output, @x, @y)
            end
            drawing_content = line_content[0..column_content_width - width - 1]
            line_content = line_content[column_content_width - width..-1]
            width += drawing_content.length

            if !row.line_limit.nil? && lines >= row.line_limit && !line_content.nil? && !line_content.empty?
              drawing_content[drawing_content.length - ELLIPSIS.length..-1] = ELLIPSIS
              protected_print @color_decorator.decorate(drawing_content, *span.styles)
              break
            else
              protected_print @color_decorator.decorate(drawing_content, *span.styles)
            end
          end
        end
        @x += column_content_width + column.margin_right
      end
    end

    def protected_print(content)
      # TODO: currently, only row overflow is detected. Definitely should handle column overflow
      return if @y < @original_y || @y > @original_y + @height - 1

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
