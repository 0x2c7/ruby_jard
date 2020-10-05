# frozen_string_literal: true

module RubyJard
  class Layouts
    WideLayout = LayoutTemplate.new(
      LayoutTemplate.new(
        ScreenTemplate.new(:source, height_ratio: 70, adjust_mode: :expand),
        ScreenTemplate.new(:backtrace, height_ratio: 30, min_height: 3),
        height_ratio: 80, width_ratio: 50
      ),
      LayoutTemplate.new(
        ScreenTemplate.new(:variables, height_ratio: 80, adjust_mode: :expand),
        ScreenTemplate.new(:threads, height_ratio: 20, min_height: 3),
        height_ratio: 80, width_ratio: 50
      ),
      ScreenTemplate.new(:menu, height: 2),
      min_width: 120,
      min_height: 24,
      fill_height: false
    )
  end
end
RubyJard::Layouts.add_layout('wide', RubyJard::Layouts::WideLayout)
