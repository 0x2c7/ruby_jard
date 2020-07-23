# frozen_string_literal: true

module RubyJard
  module Screens
    class MenuScreen < RubyJard::Screen
      def draw(output)
        RubyJard::Console.move_to(output, @x, @y)
        output.print color_decorator.decorate_element(:background, ' ' * @width)

        RubyJard::Console.move_to(output, @x, @y)
        output.print color_decorator.decorate_element(:screen_title_highlighted, ' Repl Console ')

        return if @width < 80

        margin = 0
        right_menu = [
          'Step (F7)',
          'Step Out (Shift+F7)',
          'Next (F8)',
          'Continue (F9)'
        ]

        right_menu.reverse.each do |text|
          RubyJard::Console.move_to(output, @x + @width - margin - text.length - 1, @y)

          output.print color_decorator.decorate_element(:control_buttons, text)
          margin += text.length + 3
        end
      end

      private

      def color_decorator
        @color_decorator ||= RubyJard::Decorators::ColorDecorator.new(@color_scheme)
      end
    end

    class MenuScreenNarrow < RubyJard::Screen
      def draw(output)
        RubyJard::Console.move_to(output, @x, @y)
        output.print color_decorator.decorate_element(:background, ' ' * @width)

        RubyJard::Console.move_to(output, @x, @y)
        menu = [
          'Step (F7)',
          'Step Out (Shift+F7)',
          'Next (F8)',
          'Continue (F9)'
        ]
        output.print color_decorator.decorate_element(:control_buttons, menu.join(' - '))
      end

      private

      def color_decorator
        @color_decorator ||= RubyJard::Decorators::ColorDecorator.new(@color_scheme)
      end
    end
  end
end

RubyJard::Screens.add_screen(:menu, RubyJard::Screens::MenuScreen)
RubyJard::Screens.add_screen(:menu_narrow, RubyJard::Screens::MenuScreenNarrow)
