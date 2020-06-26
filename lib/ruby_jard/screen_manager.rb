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
require 'ruby_jard/screens/stacktraces_screen'
require 'ruby_jard/screens/threads_screen'
require 'ruby_jard/screens/variables_screen'
require 'ruby_jard/screens/menu_screen'
require 'ruby_jard/layout_template'
require 'ruby_jard/layout'

module RubyJard
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
      template = pick_template(width, height)
      layout = RubyJard::Layout.generate(template: template, width: width, height: height)
      begin
        draw(layout, 0, 0)
      rescue StandardError => e
        clear_screen
        @output.puts e
        @output.puts e.backtrace
      end
    end

    private

    def clear_screen
      @output.print TTY::Cursor.clear_screen
      @output.print TTY::Cursor.move_to(0, 0)
    end

    def draw(layout, row, col)
      @output.print TTY::Cursor.move_to(col, row)

      if layout.screen.nil?
        children_row = row
        children_col = col
        drawing_width = 0
        max_height = 0
        layout.children.each do |child|
          draw(child, children_row, children_col)

          drawing_width += child.width
          max_height = child.height if max_height < child.height
          # Overflow. Spawn new line
          if drawing_width >= layout.width
            children_row += max_height
            children_col = col
            drawing_width = 0
            max_height = 0
          else
            children_col += child.width
          end
        end

        @output.print TTY::Cursor.move_to(0, children_row + 1)
      else
        screen = fetch_screen(layout.screen)
        unless screen.nil?
          screen.new(
            output: @output,
            session: @session,
            layout: layout,
            row: row,
            col: col
          ).draw
        end
      end
    end

    def fetch_screen(name)
      RubyJard::Screens[name]
    end

    def pick_template(width, height)
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
