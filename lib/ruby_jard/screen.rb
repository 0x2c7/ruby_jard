# frozen_string_literal: true

module RubyJard
  ##
  # A screen is a unit of information drawing on the terminal. Each screen is
  # generated based on input layout specifiation, screen data, and top-left
  # corner cordination.
  class Screen
    attr_accessor :layout, :rows, :window, :cursor, :selected

    def initialize(session: nil, layout:)
      @session = session || RubyJard.current_session
      @layout = layout
      @window = []
      @cursor = nil
      @selected = 0
      @rows = []
    end

    def shrinkable?
      case @layout.template.adjust_mode
      when :expand
        false
      else
        @window.length < @layout.height
      end
    end

    def expandable?
      case @layout.template.adjust_mode
      when :expand
        true
      else
        @window.length >= @layout.height
      end
    end

    def shrinkable_height
      if @window.length < @layout.height
        @layout.height - @window.length
      else
        0
      end
    end

    def move_down; end

    def move_up; end

    def page_up; end

    def page_down; end

    def click(relative_x, relative_y); end

    def build
      raise NotImplementedError, "#{self.class} should implement this method."
    end
  end
end
