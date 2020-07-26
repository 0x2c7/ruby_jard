# frozen_string_literal: true

module RubyJard
  class ScreenDrawer
    def initialize(output:, screen:, color_scheme:)
      @output = output
      @screen = screen
      @color_decorator = RubyJard::Decorators::ColorDecorator.new(color_scheme)
    end

    def draw
      @screen.window.each_with_index do |line, index|
        RubyJard::Console.move_to(@output, @screen.layout.x, @screen.layout.y + index)
        @output.print line
      end
      (@screen.window.length..@screen.layout.height - 1).each do |index|
        RubyJard::Console.move_to(@output, @screen.layout.x, @screen.layout.y + index)
        @output.print @color_decorator.decorate(:background, ' ' * @screen.layout.width)
      end
    end
  end
end
