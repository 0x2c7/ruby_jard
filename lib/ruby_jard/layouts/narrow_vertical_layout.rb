# frozen_string_literal: true

module RubyJard
  module Layouts
    NarrowVerticalLayout = RubyJard::Templates::LayoutTemplate.new(
      min_width: 40,
      min_height: 24,
      children: [
        RubyJard::Templates::LayoutTemplate.new(
          height_ratio: 80,
          width_ratio: 100,
          fill_height: true,
          fill_width: true,
          children: [
            RubyJard::Templates::ScreenTemplate.new(
              screen: :source,
              height_ratio: 60
            ),
            RubyJard::Templates::ScreenTemplate.new(
              screen: :variables,
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
RubyJard::Layouts.add_layout('narrow-vertical', RubyJard::Layouts::NarrowVerticalLayout)
