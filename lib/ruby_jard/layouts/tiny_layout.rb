# frozen_string_literal: true

module RubyJard
  class Layouts
    TinyLayout = LayoutTemplate.new(
      LayoutTemplate.new(
        ScreenTemplate.new(:source, height_ratio: 100),
        height_ratio: 80,
        width_ratio: 100
      ),
      ScreenTemplate.new(:menu, height: 2),
      min_height: 10,
      fill_height: false
    )
  end
end
RubyJard::Layouts.add_layout('tiny', RubyJard::Layouts::TinyLayout)
