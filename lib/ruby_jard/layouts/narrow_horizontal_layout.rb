# frozen_string_literal: true

module RubyJard
  class Layouts
    NarrowHorizontalLayout = LayoutTemplate.new(
      LayoutTemplate.new(
        ScreenTemplate.new(:source, width_ratio: 60),
        ScreenTemplate.new(:variables, width_ratio: 40),
        height_ratio: 80,
        width_ratio: 100
      ),
      ScreenTemplate.new(:menu, height: 2),
      min_width: 80,
      min_height: 10,
      fill_height: false
    )
  end
end
RubyJard::Layouts.add_layout('narrow-horizontal', RubyJard::Layouts::NarrowHorizontalLayout)
