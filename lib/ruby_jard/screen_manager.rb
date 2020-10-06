# frozen_string_literal: true

require 'ruby_jard/console'

require 'ruby_jard/row'
require 'ruby_jard/column'
require 'ruby_jard/span'

require 'ruby_jard/decorators/color_decorator'
require 'ruby_jard/decorators/path_decorator'
require 'ruby_jard/decorators/loc_decorator'
require 'ruby_jard/decorators/source_decorator'

require 'ruby_jard/inspectors/base'

require 'ruby_jard/screens'
require 'ruby_jard/color_schemes'
require 'ruby_jard/layouts'

require 'ruby_jard/row_renderer'
require 'ruby_jard/screen_renderer'
require 'ruby_jard/screen_adjuster'
require 'ruby_jard/box_drawer'
require 'ruby_jard/screen_drawer'

module RubyJard
  ##
  # This class acts as a coordinator, in which it combines the data and screen
  # layout template, triggers each screen to draw on the terminal.
  class ScreenManager
    attr_reader :console

    def initialize
      @console = RubyJard::Console.new
      @screens = {}
      @started = false
    end

    def start
      return if started?

      @console.clear_screen
      @started = true
    end

    def started?
      @started == true
    end

    def stop
      return unless started?

      @console.cooked!
      @console.enable_echo!
      @console.enable_cursor!

      @started = false
    end

    def draw_screens
      start unless started?

      @console.clear_screen
      @console.disable_cursor!
      @console.move_to(0, 0)

      width, height = @console.screen_size
      @layouts = calculate_layouts(width, height)
      @screens = RubyJard.benchmark(:build_screens) { build_screens(@layouts) }

      RubyJard.benchmark(:draw_box) do
        draw_box(@screens)
      end
      @screens.each do |screen|
        RubyJard.benchmark("draw_screen #{screen.class}") do
          RubyJard::ScreenDrawer.new(
            console: @console,
            screen: screen,
            color_scheme: pick_color_scheme
          ).draw
        end
      end

      @console.move_to(0, total_screen_height(@layouts) + 1)
      @console.clear_screen_to_end
    rescue StandardError => e
      @console.clear_screen
      draw_error(e)
    ensure
      # You don't want to mess up previous user TTY no matter happens
      @console.cooked!
      @console.enable_echo!
      @console.enable_cursor!
    end

    def scroll; end

    def click; end

    def draw_error(exception)
      @console.output.print RubyJard::Decorators::ColorDecorator::CSI_RESET
      @console.output.puts '--- Error ---'
      @console.output.puts "Internal error from Jard. I'm sorry to mess up your debugging experience."
      @console.output.puts 'It would be great if you can submit an issue in https://github.com/nguyenquangminh0711/ruby_jard/issues'
      @console.output.puts ''
      @console.output.puts exception
      @console.output.puts exception.backtrace
      @console.output.puts '-------------'
      RubyJard.error(exception)
    end

    private

    def calculate_layouts(width, height)
      layout = RubyJard::LayoutPicker.new(width, height).pick
      RubyJard::LayoutCalculator.calculate(
        layout_template: layout,
        width: width, height: height,
        x: 0, y: 0
      )
    end

    def build_screens(layouts)
      screens = layouts.map do |layout|
        screen_class = fetch_screen(layout.template.screen)
        screen = screen_class.new(layout)
        RubyJard.benchmark("build_screen #{screen.class}") do
          screen.build
          render_screen(screen)
        end
        screen
      end
      RubyJard::ScreenAdjuster.new(screens).adjust
      layouts.map do |layout|
        screen_class = fetch_screen(layout.template.screen)
        screen = screen_class.new(layout)
        screen.build
        render_screen(screen)
        screen
      end
    end

    def draw_box(screens)
      RubyJard::BoxDrawer.new(
        console: @console,
        screens: screens,
        color_scheme: pick_color_scheme
      ).draw
    end

    def render_screen(screen)
      RubyJard::ScreenRenderer.new(
        screen: screen,
        color_scheme: pick_color_scheme
      ).render
    end

    def fetch_screen(name)
      RubyJard::Screens[name]
    end

    def total_screen_height(layouts)
      layouts.map { |layout| layout.y + layout.height }.max || 0
    end

    def pick_color_scheme
      color_scheme_class =
        RubyJard::ColorSchemes[RubyJard.config.color_scheme] ||
        RubyJard::ColorSchemes[RubyJard::Config::DEFAULT_COLOR_SCHEME]
      color_scheme_class.new
    end
  end
end
