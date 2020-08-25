# frozen_string_literal: true

module RubyJard
  class Layouts
    TinyLayout = RubyJard::Templates::LayoutTemplate.new(
      min_height: 10,
      fill_height: false,
      children: [
        RubyJard::Templates::LayoutTemplate.new(
          height_ratio: 80,
          width_ratio: 100,
          min_height: 7,
          fill_height: true,
          children: [
            RubyJard::Templates::ScreenTemplate.new(
              screen: :source,
              height_ratio: 100
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
RubyJard::Layouts.add_layout('tiny', RubyJard::Layouts::TinyLayout)
