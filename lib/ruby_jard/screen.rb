# frozen_string_literal: true

module RubyJard
  ##
  # A screen is a unit of information drawing on the terminal. Each screen is
  # generated based on input layout specifiation, screen data, and top-left
  # corner cordination.
  class Screen
    attr_reader :output

    def initialize(screen_template:, output:, session:, width:, height:, row:, col:)
      @output = output
      @session = session
      @screen_template = screen_template
      @width = width
      @height = height
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
      row_template.priorities.each do |priority|
        @rows = data_window.map.with_index do |data_row, index|
          create_row(row_template, priority, data_row, index)
        end
        calculate_column_widths(row_template, @rows)

        break unless need_to_ommit?(@rows)
      end
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
      oversize_columns = fetch_oversize_columns(row_template, rows)
      if oversize_columns.empty?
        fill_fit_column_widths(rows)
      else
        fill_oversize_column_widths(row_template, rows, oversize_columns)
      end
    end

    def fetch_oversize_columns(row_template, rows)
      oversize_columns = []
      ideal_column_width = @width / row_template.columns.length
      row_template.columns.each_with_index do |_column_template, column_index|
        rows.each do |row|
          column = row.columns[column_index]
          if column.content_length > ideal_column_width
            oversize_columns << column_index
            break
          end
        end
      end
      oversize_columns
    end

    def fill_fit_column_widths(rows)
      total_column_width = 0
      rows.each do |row|
        row.columns.each_with_index do |column, column_index|
          if column_index == row.columns.length - 1
            column.width = @width - total_column_width
          else
            column.width = column.content_length
            total_column_width += column.width
          end
        end
      end
    end

    def fill_oversize_column_widths(row_template, rows, oversize_columns)
      fit_columns = (0..row_template.columns.length - 1).to_a - oversize_columns
      oversize_column_width = (@width - total_column_width(rows, fit_columns)) / oversize_columns.length

      rows.each do |row|
        total_width = 0
        row.columns.each_with_index do |column, column_index|
          column.width =
            if column_index == row.columns.length - 1
              @width - total_width
            elsif oversize_columns.include?(column_index)
              oversize_column_width
            else
              column.content_length
            end
          total_width += column.width
        end
      end
    end

    def total_column_width(rows, target_columns)
      total = 0
      rows.first.columns.each_with_index do |c, index|
        total += c.width if target_columns.include?(index)
      end
      total
    end

    def create_row(row_template, priority, data_row, index)
      row = Row.new(row_template: row_template, priority: priority)
      row.columns = row_template.columns.map do |column_template|
        create_column(column_template, priority, data_row, index)
      end
      row
    end

    def create_column(column_template, priority, data_row, index)
      column = Column.new(column_template: column_template)
      column.spans = column_template.spans.map do |span_template|
        next if span_template.priority > priority

        create_span(span_template, data_row, index)
      end
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
        content = ' ' * span_template.margin_left + content if span_template.margin_left
        content += ' ' * span_template.margin_right if span_template.margin_right
        span.content = content
        span.styles = styles.to_a.compact
        span.content_length = span.content.length
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

    def decorate_loc(loc, highlighted)
      # TODO: this interface is ugly as fuck
      RubyJard::Decorators::LocDecorator.new(@color_decorator, loc, highlighted)
    end
  end
end
