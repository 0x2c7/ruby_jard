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
          min_height: 7,
          fill_height: true,
          children: [
            RubyJard::Templates::ScreenTemplate.new(
              screen: :source,
              height_ratio: 60
            ),
            RubyJard::Templates::ScreenTemplate.new(
              screen: :variables,
              width_ratio: 100,
              height_ratio: 40,
              min_height: 3
            )
          ]
        ),
        RubyJard::Templates::LayoutTemplate.new(
          height_ratio: 80,
          width_ratio: 50,
          fill_height: true,
          children: [
            RubyJard::Templates::ScreenTemplate.new(
              screen: :backtrace,
              height_ratio: 50,
              fill_height: true
            ),
            RubyJard::Templates::ScreenTemplate.new(
              screen: :threads,
              height_ratio: 50,
              fill_height: true
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
