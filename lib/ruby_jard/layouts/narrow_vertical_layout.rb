# frozen_string_literal: true

module RubyJard
  class Layouts
    NarrowVerticalLayout = LayoutTemplate.new(
      LayoutTemplate.new(
        ScreenTemplate.new(:source, height_ratio: 60),
        ScreenTemplate.new(:variables, height_ratio: 40),
        height_ratio: 80,
        width_ratio: 100
      ),
      ScreenTemplate.new(:menu, height: 2),
      min_width: 40,
      min_height: 24,
      fill_height: false
    )
  end
end
RubyJard::Layouts.add_layout('narrow-vertical', RubyJard::Layouts::NarrowVerticalLayout)
