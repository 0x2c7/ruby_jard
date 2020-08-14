# frozen_string_literal: true

module RubyJard
  module Layouts
    TinyLayout = RubyJard::Templates::LayoutTemplate.new(
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
              height_ratio: 100
            )
          ]
        )
      ]
    )
  end
end
RubyJard::Layouts.add_layout('tiny', RubyJard::Layouts::TinyLayout)
