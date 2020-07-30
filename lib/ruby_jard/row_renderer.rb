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
      @original_x = 0
      @original_y = 0
      @content_map = []

      @row.columns.each do |column|
        @x = @original_x
        @y = @original_y

        @drawing_width = 0
        @drawing_lines = 1

        column.spans.each do |span|
          render_span(column, span)
        end

        @original_x += column.width
      end

      generate_bitmap
    end

    # rubocop:disable Metrics/MethodLength
    def render_span(column, span)
      line_content = span.content

      until line_content.nil? || line_content.empty?
        if column.word_wrap == RubyJard::Column::WORD_WRAP_NORMAL
          if column.content_width - @drawing_width < line_content.length && @drawing_width != 0
            @drawing_width = 0
            @drawing_lines += 1
            @y += 1
            @x = @original_x
          end
        elsif column.word_wrap == RubyJard::Column::WORD_WRAP_BREAK_WORD
          if column.content_width - @drawing_width <= 0
            @drawing_width = 0
            @drawing_lines += 1
            @y += 1
            @x = @original_x
          end
        elsif column.content_width - @drawing_width <= 0
          return
        end
        drawing_content = line_content[0..column.content_width - @drawing_width - 1]
        line_content = line_content[column.content_width - @drawing_width..-1]
        @drawing_width += drawing_content.length

        if !@row.line_limit.nil? &&
           @drawing_lines >= @row.line_limit &&
           !line_content.nil? &&
           !line_content.empty?
          drawing_content[drawing_content.length - ELLIPSIS.length..-1] = ELLIPSIS
          draw_content(drawing_content, span.styles)
          return
        else
          draw_content(drawing_content, span.styles)
        end
      end
    end
    # rubocop:enable Metrics/MethodLength

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
