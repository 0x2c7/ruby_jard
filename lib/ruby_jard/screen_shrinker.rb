# frozen_string_literal: true

module RubyJard
  ##
  # Implement elastic screen height. If a screen is shrinkable (which means)
  # its current window is less than its height, it will be forced to give
  # away those spaces to other screens. This layout adjustment is small, and
  # should not affect the original generated layout too much, nor work with
  # nested layout.
  class ScreenShrinker
    def initialize(screens)
      @screens = screens
    end

    def shrink
      groups = @screens.group_by { |screen| screen.layout.parent_template }
      groups.each do |_, grouped_screens|
        next if grouped_screens.length <= 1

        grouped_screens.sort_by! { |screen| screen.layout.box_y }
        shrinkable_screens = grouped_screens.select(&:shrinkable?)
        expandable_screens = grouped_screens.reject(&:shrinkable?)

        next if shrinkable_screens.empty? || expandable_screens.empty?

        budget = shrinkable_screens.map(&:schrinkable_height).sum
        expand_screens(expandable_screens, budget)
        shrink_screens(shrinkable_screens)
        compact_screens(grouped_screens)
      end
    end

    private

    def expand_screens(expandable_screens, budget)
      budget_each = budget / expandable_screens.length

      expandable_screens.each_with_index do |screen, index|
        if index == expandable_screens.length - 1
          screen.layout.height += budget
          screen.layout.box_height += budget
        else
          screen.layout.height += budget_each
          screen.layout.box_height += budget_each
          budget_each -= budget_each
        end
      end
    end

    def shrink_screens(shrinkable_screens)
      shrinkable_screens.each do |screen|
        delta = screen.schrinkable_height
        screen.layout.height -= delta
        screen.layout.box_height -= delta
      end
    end

    def compact_screens(screens)
      box_y = screens.first.layout.box_y
      screens.each do |screen|
        screen.layout.box_y = box_y
        screen.layout.y = box_y + 1
        box_y += screen.layout.box_height - 1
      end
    end
  end
end
