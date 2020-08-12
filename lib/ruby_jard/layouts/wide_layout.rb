# frozen_string_literal: true

module RubyJard
  module Layouts
    WideLayout = RubyJard::Templates::LayoutTemplate.new(
      min_width: 120,
      min_height: 10,
      fill_width: true,
      children: [
        RubyJard::Templates::LayoutTemplate.new(
          height_ratio: 80,
          width_ratio: 50,
          fill_height: true,
          children: [
            RubyJard::Templates::ScreenTemplate.new(
              screen: :source,
              height_ratio: 70
            ),
            RubyJard::Templates::ScreenTemplate.new(
              screen: :backtrace,
              height_ratio: 30
            )
          ]
        ),
        RubyJard::Templates::LayoutTemplate.new(
          height_ratio: 80,
          width_ratio: 50,
          fill_height: true,
          children: [
            RubyJard::Templates::ScreenTemplate.new(
              screen: :variables,
              height_ratio: 60
            ),
            RubyJard::Templates::ScreenTemplate.new(
              screen: :threads,
              height_ratio: 40
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
