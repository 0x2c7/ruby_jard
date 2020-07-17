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
      RubyJard::Console.start_alternative_terminal(@output)
      RubyJard::Console.hard_clear_screen(@output)
    end

    def stop
      RubyJard::Console.stop_alternative_terminal(@output)
      RubyJard::Console.show_cursor(@output)
    end

    def update
      RubyJard::Console.hide_cursor(@output)
      clear_screen
      width, height = RubyJard::Console.screen_size(@output)
      screen_layouts = calculate_layouts(width, height)
      draw_screens(screen_layouts)
      jump_to_prompt(screen_layouts)
      draw_debug(width, height)
    rescue StandardError => e
      clear_screen
      draw_error(width, height, e)
    ensure
      # You don't want to mess up previous user TTY no matter happens
      RubyJard::Console.cooked!(@output)
      RubyJard::Console.echo!(@output)
      RubyJard::Console.show_cursor(@output)
    end

    private

    def calculate_layouts(width, height)
      layout = pick_layout(width, height)
      RubyJard::Layout.calculate(
        layout: layout,
        width: width, height: height,
        x: 0, y: 0
      )
    end

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

    def jump_to_prompt(screen_layouts)
      prompt_y = screen_layouts.map { |_template, _width, screen_height, _x, y| y + screen_height }.max
      RubyJard::Console.move_to(@output, 0, prompt_y)
    end

    def draw_debug(_width, height)
      unless RubyJard.debug_info.empty?
        @output.puts '--- Debug ---'
        RubyJard.debug_info.first(height - 2).each do |line|
          @output.puts line
        end
        @output.puts '-------------'
      end
      RubyJard.clear_debug
    end

    def draw_error(height, _width, exception)
      @output.puts '--- Error ---'
      @output.puts "Internal error from Jard. I'm sorry to mess up your debugging experience."
      @output.puts 'It would be great if you can submit an issue in https://github.com/nguyenquangminh0711/ruby_jard/issues'
      @output.puts ''
      @output.puts exception
      @output.puts exception.backtrace.first(height - 5)
      @output.puts '-------------'
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
