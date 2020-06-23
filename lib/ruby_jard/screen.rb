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
      @color = Pastel.new
    end

    def draw(_row, _col, _size)
      raise NotImplementedError, "#{self.class} must implement #draw method"
    end

    def decorate
      RubyJard::Decorators::TextDecorator.new(@color)
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
