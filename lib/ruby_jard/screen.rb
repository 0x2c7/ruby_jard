# frozen_string_literal: true

module RubyJard
  ##
  # A screen is a unit of information drawing on the terminal. Each screen is
  # generated based on input layout specifiation, screen data, and top-left
  # corner cordination.
  class Screen
    attr_reader :output, :rows, :width, :height

    def initialize(screen_template:, output:, session:, width:, height:, row:, col:)
      @session = session
      @screen_template = screen_template
      @width = width
      @height = height

      # TODO: remove these variables after refactoring
      @output = output
      @row = row
      @col = col
      @color_decorator = Pastel.new
    end

    def draw(_row, _col, _size)
      raise NotImplementedError, "#{self.class} must implement #draw method"
    end

    def data_size
      raise NotImplementedError, "#{self.class} must implement #data_size method"
    end

    def data_window
      raise NotImplementedError, "#{self.class} must implement #data_window method"
    end

    def calculate
      @rows = []
      row_template = @screen_template.row_template
      @rows = data_window.map.with_index do |data_row, index|
        create_row(row_template, data_row, index)
      end
      column_widths = calculate_column_widths(row_template, @rows)
      fill_column_widths(@rows, column_widths)
    end

    private

    def adjust_screen_size_to_borders
      # TODO: In future, borders are dynamic decided by layout. Right now, each screen has top and left border
      @width -= 1
      @height -= 1
      @row += 1
      @col += 1
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

    def calculate_column_widths(row_template, rows)
      column_widths = {}
      ideal_column_width = @width / row_template.columns.length
      row_template.columns.each_with_index do |_column_template, column_index|
        column_widths[column_index] ||= 0
        rows.each do |row|
          column = row.columns[column_index]
          if column.content_length > ideal_column_width
            column_widths[column_index] = nil
            break
          elsif column.content_length > column_widths[column_index]
            column_widths[column_index] = column.content_length
          end
        end
      end
      column_widths
    end

    def fill_column_widths(rows, column_widths)
      fixed_count = column_widths.length
      fixed_width = column_widths.values.inject(0) do |sum, col|
        col.nil? ? sum : sum + col
      end

      rows.each do |row|
        total_width = 0
        row.columns.each_with_index do |column, column_index|
          column.width =
            if column_index == row.columns.length - 1
              @width - total_width
            elsif column_widths[column_index].nil?
              (@width - fixed_width) / fixed_count
            else
              column_widths[column_index]
            end
          total_width += column.width
        end
      end
    end

    def create_row(row_template, data_row, index)
      row = Row.new(row_template: row_template)
      row.columns = row_template.columns.map do |column_template|
        create_column(column_template, data_row, index)
      end
      row
    end

    def create_column(column_template, data_row, index)
      column = Column.new(column_template: column_template)
      column.spans = column_template.spans.map do |span_template|
        create_span(span_template, data_row, index)
      end.flatten
      column.content_length =
        column.spans.map(&:content_length).inject(&:+) +
        column.margin_left +
        column.margin_right
      column
    end

    def create_span(span_template, data_row, index)
      span = Span.new(span_template: span_template)
      span_content_method = "span_#{span_template.name}".to_sym

      if respond_to?(span_content_method)
        content, styles = send(span_content_method, data_row, index)
        if content.nil?
          span.content = ''
          span.content_length = 0
        elsif content.is_a?(Array)
          content.each do |sub_span|
            sub_span.styles += Array(styles).flatten.compact
          end
          return content
        else
          content = ' ' * span_template.margin_left + content if span_template.margin_left
          content += ' ' * span_template.margin_right if span_template.margin_right
          span.content = content
          span.styles = Array(styles).flatten.compact
          span.content_length = span.content.length
        end
      else
        raise NotImplementedError, "#{self.class} must implement #{span_content_method} method"
      end

      span
    end

    def need_to_ommit?(rows)
      # TODO: Implement the ommision condition here
      # Idea:
      # - Ommit if the row height > height limit
      false
    end

    def decorate_text
      # TODO: this interface is ugly as fuck
      RubyJard::Decorators::TextDecorator.new(@color_decorator)
    end

    def decorate_path(path, lineno)
      # TODO: this interface is ugly as fuck
      RubyJard::Decorators::PathDecorator.new(path, lineno)
    end

    def decorate_source(file, lineno, window)
      # TODO: this interface is ugly as fuck
      RubyJard::Decorators::SourceDecorator.new(file, lineno, window)
    end

    def decorate_loc(loc)
      # TODO: this interface is ugly as fuck
      RubyJard::Decorators::LocDecorator.new(loc)
    end
  end
end
