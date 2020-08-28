# frozen_string_literal: true

module RubyJard
  ##
  # Adjust the layout between screens, render row's bitmap by calling RowRenderer,
  # calculate screen window to ready for putting on the screen.
  class ScreenRenderer
    def initialize(screen:, color_scheme:)
      @screen = screen
      @color_scheme = color_scheme
    end

    def render
      # Move this logic into a class called SreenRenderer
      calculate_content_lengths
      column_widths = calculate_column_widths
      adjust_column_widths(column_widths)
      calculate_window

      @screen
    end

    private

    def calculate_content_lengths
      @screen.rows.each do |row|
        row.columns.each do |column|
          column.content_length = column.spans.map(&:content_length).inject(&:+) || 0
        end
      end
    end

    def calculate_column_widths
      column_widths = {}
      total_columns = count_columns

      return column_widths if total_columns == 0

      ideal_column_width = @screen.layout.width / total_columns
      total_columns.times do |column_index|
        column_widths[column_index] ||= 0
        @screen.rows.each do |row|
          column = row.columns[column_index]
          if column.content_length > ideal_column_width - 1
            column_widths[column_index] = nil
            break
          elsif column.content_length + 1 > column_widths[column_index]
            column_widths[column_index] = column.content_length + 1
          end
        end
      end
      column_widths
    end

    def adjust_column_widths(column_widths)
      dynamic_count = count_dynamic_columns(column_widths)
      fixed_width = sum_fixed_width(column_widths)

      @screen.rows.each do |row|
        total_width = 0
        row.columns.each_with_index do |column, column_index|
          column.width =
            if column_index == row.columns.length - 1
              @screen.layout.width - total_width
            elsif column_widths[column_index].nil?
              (@screen.layout.width - fixed_width) / dynamic_count
            else
              column_widths[column_index]
            end
          column.content_width = column.width
          column.content_width -= 1 if column_index < row.columns.length - 1

          total_width += column.width
        end
      end
    end

    def count_dynamic_columns(column_widths)
      column_widths.values.select(&:nil?).length
    end

    def sum_fixed_width(column_widths)
      column_widths.values.inject(0) do |sum, col|
        col.nil? ? sum : sum + col
      end
    end

    def render_rows
      @screen.rows.each do |row|
      end
    end

    def calculate_window
      @screen.window = []

      if @screen.cursor.nil?
        find_seleted_window
      else
        find_cursor_window
      end
    end

    def find_seleted_window
      @screen.rows.each_with_index do |row, row_index|
        row_content(row).each_with_index do |line, line_index|
          if @screen.window.length < @screen.layout.height
            @screen.window << line
          elsif row_index < @screen.selected
            @screen.window = [line]
          elsif row_index == @screen.selected
            if line_index != 0
              @screen.window.shift
              @screen.window << line
            else
              @screen.window = [line]
            end
          else
            return
          end
        end
      end
    end

    def find_cursor_window
      cursor_line = -1
      @screen.rows.each do |row|
        row_content(row).each do |line|
          cursor_line += 1
          @screen.window << line if cursor_line >= @screen.cursor
          return if @screen.window.length >= @screen.layout.height
        end
      end
    end

    def count_columns
      @screen.rows.map { |row| row.columns.count }.max.to_i
    end

    def row_content(row)
      unless row.rendered?
        RubyJard::RowRenderer.new(
          row: row,
          width: @screen.layout.width,
          height: @screen.layout.height,
          color_scheme: @color_scheme
        ).render
      end

      row.content
    end
  end
end
