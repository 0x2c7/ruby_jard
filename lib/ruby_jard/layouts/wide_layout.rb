# frozen_string_literal: true

module RubyJard
  class Layouts
    WideLayout = RubyJard::Templates::LayoutTemplate.new(
      min_width: 120,
      min_height: 24,
      fill_height: false,
      children: [
        RubyJard::Templates::LayoutTemplate.new(
          height_ratio: 80,
          width_ratio: 50,
          children: [
            RubyJard::Templates::ScreenTemplate.new(
              screen: :source,
              height_ratio: 70,
              adjust_mode: :expand
            ),
            RubyJard::Templates::ScreenTemplate.new(
              screen: :backtrace,
              height_ratio: 30,
              min_height: 3
            )
          ]
        ),
        RubyJard::Templates::LayoutTemplate.new(
          height_ratio: 80,
          width_ratio: 50,
          children: [
            RubyJard::Templates::ScreenTemplate.new(
              screen: :variables,
              height_ratio: 80,
              adjust_mode: :expand
            ),
            RubyJard::Templates::ScreenTemplate.new(
              screen: :threads,
              height_ratio: 20,
              min_height: 3
            )
          ]
        ),
        RubyJard::Templates::ScreenTemplate.new(
          height: 2,
          screen: :menu
        )
      ]
    )
  end
end
RubyJard::Layouts.add_layout('wide', RubyJard::Layouts::WideLayout)
