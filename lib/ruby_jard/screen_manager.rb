# frozen_string_literal: true

require 'ruby_jard/console'

require 'ruby_jard/decorators/color_decorator'
require 'ruby_jard/decorators/path_decorator'
require 'ruby_jard/decorators/loc_decorator'
require 'ruby_jard/decorators/source_decorator'

require 'ruby_jard/screen'
require 'ruby_jard/box_drawer'
require 'ruby_jard/screen_drawer'
require 'ruby_jard/screens'
require 'ruby_jard/screens/source_screen'
require 'ruby_jard/screens/backtrace_screen'
require 'ruby_jard/screens/threads_screen'
require 'ruby_jard/screens/variables_screen'
require 'ruby_jard/screens/menu_screen'

require 'ruby_jard/templates/layout_template'
require 'ruby_jard/templates/screen_template'
require 'ruby_jard/templates/row_template'
require 'ruby_jard/templates/column_template'
require 'ruby_jard/templates/span_template'
require 'ruby_jard/templates/space_template'

require 'ruby_jard/layouts/wide_layout'
require 'ruby_jard/layout'
require 'ruby_jard/row'
require 'ruby_jard/column'
require 'ruby_jard/span'

module RubyJard
  ##
  # This class acts as a coordinator, in which it combines the data and screen
  # layout template, triggers each screen to draw on the terminal.
  class ScreenManager
    attr_reader :output

    def initialize(session:, output: STDOUT)
      @output = output
      @session = session
      @screens = {}
    end

    def start
      refresh
    end

    def refresh
      RubyJard::Console.hide_cursor(@output)
      clear_screen

      width, height = RubyJard::Console.screen_size(@output)
      layout = pick_layout(width, height)
      screen_layouts = RubyJard::Layout.calculate(
        layout: layout,
        width: width, height: height,
        x: 0, y: 0
      )

      prompt_y = screen_layouts.map { |_template, _width, screen_height, _x, y| y + screen_height }.max
      begin
        draw_screens(screen_layouts)
      rescue StandardError => e
        clear_screen
        @output.puts e, e.backtrace
      end
      RubyJard::Console.move_to(@output, 0, prompt_y)
      print_debug_screen

      RubyJard::Console.show_cursor(@output)
    end

    private

    def draw_box(screens)
      RubyJard::BoxDrawer.new(
        output: @output,
        screens: screens
      ).draw
    end

    def draw_screens(screen_layouts)
      screens = screen_layouts.map do |screen_template, width, height, x, y|
        screen = fetch_screen(screen_template.screen)
        screen&.new(
          session: @session,
          screen_template: screen_template,
          width: width, height: height,
          x: x, y: y
        )
      end
      draw_box(screens)
      adjust_screen_contents(screens)
      screens.each do |screen|
        screen.draw(@output)
      end
    end

    def adjust_screen_contents(screens)
      # After drawing the box, screen sizes should be updated to reflect content-only area
      screens.each do |screen|
        screen.width -= 2
        screen.height -= 2
        screen.x += 1
        screen.y += 1
      end
    end

    def print_debug_screen
      unless RubyJard.debug_info.empty?
        @output.puts '--- Debug ---'
        RubyJard.debug_info.each do |line|
          @output.puts line
        end
        @output.puts '-------------'
      end
      RubyJard.clear_debug
    end

    def clear_screen
      RubyJard::Console.clear_screen(@output)
    end

    def fetch_screen(name)
      RubyJard::Screens[name]
    end

    def pick_layout(width, height)
      RubyJard::DEFAULT_LAYOUT_TEMPLATES.each do |template|
        matched = true
        matched &&= (
          template.min_width.nil? ||
          width > template.min_width
        )
        matched &&= (
          template.min_height.nil? ||
          height > template.min_height
        )
        return template if matched
      end
      RubyJard::DEFAULT_LAYOUT_TEMPLATES.first
    end
  end
end
