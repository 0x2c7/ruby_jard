# frozen_string_literal: true

require 'ruby_jard/decorators/text_decorator'
require 'ruby_jard/decorators/path_decorator'
require 'ruby_jard/decorators/loc_decorator'
require 'ruby_jard/decorators/source_decorator'

require 'ruby_jard/screen'
require 'ruby_jard/screens'
require 'ruby_jard/screens/breakpoints_screen'
require 'ruby_jard/screens/expressions_sreen'
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
      clear_screen
      width = TTY::Screen.width
      height = TTY::Screen.height
      layout = pick_layout(width, height)
      screens = RubyJard::Layout.calculate(
        layout: layout,
        width: width, height: height,
        row: 0, col: 0
      )

      begin
        draw_screens(screens)
      rescue StandardError => e
        clear_screen
        @output.puts e
        @output.puts e.backtrace
      end
    end

    private

    def draw_screens(screens)
      screens.each do |screen_template, width, height, row, col|
        # puts screen_template, screen_template.screen, width, height, row, col
        screen = fetch_screen(screen_template.screen)
        screen&.new(
          output: @output,
          session: @session,
          screen_template: screen_template,
          width: width,
          height: height,
          row: row,
          col: col
        )&.draw
      end

      cursor_row = screens.map { |_, _, height, row, _| row + height }.max
      @output.puts TTY::Cursor.move_to(0, cursor_row)
    end

    def clear_screen
      @output.print TTY::Cursor.clear_screen
      @output.print TTY::Cursor.move_to(0, 0)
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
