# frozen_string_literal: true

module RubyJard
  class Screen
    attr_reader :output

    def initialize(layout:, output:, session:, row:, col:)
      @output = output
      @session = session
      @layout = layout
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
          border: {
            fg: :dim
          }
        },
        border: {
          bottom_left: false,
          bottom_right: false,
          right: false,
          bottom: false,
          left: false
        }
      }
    end
  end
end
