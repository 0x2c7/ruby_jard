# frozen_string_literal: true

module RubyJard
  module Layouts
    NarrowLayout = RubyJard::Templates::LayoutTemplate.new(
      min_width: 60,
      min_height: 10,
      children: [
        RubyJard::Templates::LayoutTemplate.new(
          height_ratio: 80,
          width_ratio: 100,
          min_height: 7,
          fill_height: true,
          children: [
            RubyJard::Templates::ScreenTemplate.new(
              screen: :source,
              height_ratio: 60
            ),
            RubyJard::Templates::LayoutTemplate.new(
              height_ratio: 40,
              width_ratio: 100,
              fill_height: true,
              children: [
                RubyJard::Templates::ScreenTemplate.new(
                  screen: :variables,
                  width_ratio: 100,
                  height_ratio: 100,
                  min_height: 3
                )
              ]
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
RubyJard::Layouts.add_layout('narrow', RubyJard::Layouts::NarrowLayout)
