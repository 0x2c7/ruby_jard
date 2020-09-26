# frozen_string_literal: true

module RubyJard
  ##
  # Draw rendered screen bitmap in current screen window onto the screen.
  # Fulfill missing window if needed
  class ScreenDrawer
    def initialize(console:, screen:, color_scheme:)
      @console = console
      @screen = screen
      @color_decorator = RubyJard::Decorators::ColorDecorator.new(color_scheme)
    end

    def draw
      @screen.window.each_with_index do |line, index|
        @console.move_to(@screen.layout.x, @screen.layout.y + index)
        @console.print line
      end
      (@screen.window.length..@screen.layout.height - 1).each do |index|
        @console.move_to(@screen.layout.x, @screen.layout.y + index)
        @console.print @color_decorator.decorate(:background, ' ' * @screen.layout.width)
      end
    end
  end
end
