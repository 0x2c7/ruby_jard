# frozen_string_literal: true

module RubyJard
  class Layouts
    NarrowHorizontalLayout = RubyJard::Templates::LayoutTemplate.new(
      min_width: 80,
      min_height: 10,
      fill_height: false,
      children: [
        RubyJard::Templates::LayoutTemplate.new(
          height_ratio: 80,
          width_ratio: 100,
          children: [
            RubyJard::Templates::ScreenTemplate.new(
              screen: :source,
              width_ratio: 60
            ),
            RubyJard::Templates::ScreenTemplate.new(
              screen: :variables,
              width_ratio: 40
            )
          ]
        )
      ]
    )
  end
end
RubyJard::Layouts.add_layout('narrow-horizontal', RubyJard::Layouts::NarrowHorizontalLayout)
