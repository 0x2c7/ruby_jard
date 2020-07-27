# frozen_string_literal: true

module RubyJard
  ##
  # Generate bitmap lines from a row's data
  class RowRenderer
    ELLIPSIS = ' »'

    def initialize(row:, width:, height:, color_scheme:)
      @row = row
      @width = width
      @height = height
      @color_decorator = RubyJard::Decorators::ColorDecorator.new(color_scheme)
    end

    def render
      @x = 0
      @y = 0
      @content_map = []

      original_x = 0
      @row.columns.each_with_index do |column, index|
        @y = 0
        @x = original_x
        content_width = column.width
        content_width -= 1 if index < @row.columns.length - 1
        render_column(column, original_x, content_width)

        original_x += column.width
      end

      generate_bitmap
    end

    def render_column(column, original_x, content_width)
      width = 0
      lines = 1

      column.spans.each do |span|
        line_content = span.content

        until line_content.nil? || line_content.empty?
          if content_width - width < line_content.length && width != 0
            width = 0
            lines += 1
            @y += 1
            @x = original_x
          end
          drawing_content = line_content[0..content_width - width - 1]
          line_content = line_content[content_width - width..-1]
          width += drawing_content.length

          if !@row.line_limit.nil? && lines >= @row.line_limit && !line_content.nil? && !line_content.empty?
            drawing_content[drawing_content.length - ELLIPSIS.length..-1] = ELLIPSIS
            draw_content(drawing_content, span.styles)
            return
          else
            draw_content(drawing_content, span.styles)
          end
        end
      end
    end

    def draw_content(drawing_content, styles)
      return if @y < 0 || @y >= @height

      @content_map[@y] ||= []
      @content_map[@y][@x] = [styles, drawing_content]
      @x += drawing_content.length
    end

    def generate_bitmap
      @row.content = []
      @content_map.each do |line|
        line_content = ''
        pending_content = ''

        cell_index = 0
        while cell_index < @width
          cell = line[cell_index]
          if cell.nil? || cell[1].empty?
            pending_content += ' '
            cell_index += 1
          else
            line_content += @color_decorator.decorate(:background, pending_content)
            line_content += @color_decorator.decorate(cell[0], cell[1])
            pending_content = ''
            cell_index += cell[1].length
          end
        end

        line_content += @color_decorator.decorate(:background, pending_content) unless pending_content.empty?
        @row.content << line_content
      end
    end
  end
end
