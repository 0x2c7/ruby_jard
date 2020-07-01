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

    private

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
