# frozen_string_literal: true

require 'ruby_jard/console'

require 'ruby_jard/decorators/color_decorator'
require 'ruby_jard/decorators/path_decorator'
require 'ruby_jard/decorators/loc_decorator'
require 'ruby_jard/decorators/source_decorator'
require 'ruby_jard/decorators/inspection_decorator'

require 'ruby_jard/screen'
require 'ruby_jard/screens'

require 'ruby_jard/color_scheme'
require 'ruby_jard/color_schemes'
require 'ruby_jard/color_schemes/deep_space_color_scheme'
require 'ruby_jard/color_schemes/256_color_scheme'

require 'ruby_jard/row'
require 'ruby_jard/column'
require 'ruby_jard/span'
require 'ruby_jard/row_renderer'
require 'ruby_jard/screen_renderer'
require 'ruby_jard/box_drawer'
require 'ruby_jard/screen_drawer'

require 'ruby_jard/screens/source_screen'
require 'ruby_jard/screens/backtrace_screen'
require 'ruby_jard/screens/threads_screen'
require 'ruby_jard/screens/variables_screen'
require 'ruby_jard/screens/menu_screen'

require 'ruby_jard/templates/layout_template'
require 'ruby_jard/templates/screen_template'

require 'ruby_jard/layouts/wide_layout'
require 'ruby_jard/layouts/narrow_layout'
require 'ruby_jard/layout'
require 'ruby_jard/layout_calculator'

module RubyJard
  ##
  # This class acts as a coordinator, in which it combines the data and screen
  # layout template, triggers each screen to draw on the terminal.
  class ScreenManager
    class << self
      extend Forwardable

      def_delegators :instance, :update, :draw_error, :started?, :updating?

      def instance
        @instance ||= new
      end
    end

    attr_reader :output, :output_storage

    def initialize(output: STDOUT)
      @output = output
      @screens = {}
      @started = false
      @updating = false
      @output_storage = StringIO.new
    end

    def start
      return if started?

      # Load configurations
      RubyJard.config
      RubyJard::Console.start_alternative_terminal(@output)
      RubyJard::Console.clear_screen(@output)

      def $stdout.write(string)
        if !RubyJard::ScreenManager.updating? && RubyJard::ScreenManager.started?
          RubyJard::ScreenManager.instance.output_storage.write(string)
        end
        super
      end

      at_exit { stop }
      @started = true
    end

    def started?
      @started == true
    end

    def updating?
      @updating == true
    end

    def stop
      return unless started?

      @started = false

      RubyJard::Console.stop_alternative_terminal(@output)
      RubyJard::Console.cooked!
      RubyJard::Console.enable_echo!
      RubyJard::Console.enable_cursor!

      unless @output_storage.string.empty?
        @output.puts ''
        @output.write @output_storage.string
        @output.puts ''
      end
      @output_storage.close
    end

    def update
      start unless started?
      @updating = true

      RubyJard::Console.disable_cursor!
      width, height = RubyJard::Console.screen_size(@output)

      @layouts = calculate_layouts(width, height)
      @screens = build_screens(@layouts)
      draw_box(@screens)
      draw_screens(@screens)

      RubyJard::Console.move_to(@output, 0, total_screen_height(@layouts) + 1)
      RubyJard::Console.clear_screen_to_end(@output)

      draw_debug(width, height)
    rescue StandardError => e
      RubyJard::Console.clear_screen(@output)
      draw_error(e, height)
    ensure
      # You don't want to mess up previous user TTY no matter happens
      RubyJard::Console.cooked!
      RubyJard::Console.enable_echo!
      RubyJard::Console.enable_cursor!
      @updating = false
    end

    def scroll; end

    def click; end

    def draw_error(exception, height = 0)
      @output.print RubyJard::Decorators::ColorDecorator::CSI_RESET
      @output.puts '--- Error ---'
      @output.puts "Internal error from Jard. I'm sorry to mess up your debugging experience."
      @output.puts 'It would be great if you can submit an issue in https://github.com/nguyenquangminh0711/ruby_jard/issues'
      @output.puts ''
      @output.puts exception
      if height == 0
        @output.puts exception.backtrace
      else
        @output.puts exception.backtrace.first(10)
      end
      @output.puts '-------------'
    end

    private

    def calculate_layouts(width, height)
      layout = pick_layout(width, height)
      RubyJard::LayoutCalculator.calculate(
        layout_template: layout,
        width: width, height: height,
        x: 0, y: 0
      )
    end

    def build_screens(layouts)
      layouts.map do |layout|
        screen_class = fetch_screen(layout.template.screen)
        screen = screen_class.new(
          layout: layout,
          color_scheme: pick_color_scheme
        )
        screen.build
        render_screen(screen)
        screen
      end
    end

    def draw_box(screens)
      RubyJard::BoxDrawer.new(
        output: @output,
        screens: screens,
        color_scheme: pick_color_scheme
      ).draw
    end

    def draw_screens(screens)
      screens.each do |screen|
        RubyJard::ScreenDrawer.new(
          output: @output,
          screen: screen,
          color_scheme: pick_color_scheme
        ).draw
      end
    end

    def render_screen(screen)
      RubyJard::ScreenRenderer.new(
        screen: screen,
        color_scheme: pick_color_scheme
      ).render
    end

    def draw_debug(_width, height)
      @output.print RubyJard::Decorators::ColorDecorator::CSI_RESET
      unless RubyJard.debug_info.empty?
        @output.puts '--- Debug ---'
        RubyJard.debug_info.first(height - 2).each do |line|
          @output.puts line
        end
        @output.puts '-------------'
      end
      RubyJard.clear_debug
    end

    def fetch_screen(name)
      RubyJard::Screens[name]
    end

    def total_screen_height(layouts)
      layouts.map { |layout| layout.y + layout.height }.max
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

    def pick_color_scheme
      color_scheme_class =
        RubyJard::ColorSchemes[RubyJard.config.color_scheme] ||
        RubyJard::ColorSchemes[RubyJard::Config::DEFAULT_COLOR_SCHEME]
      color_scheme_class.new
    end
  end
end
