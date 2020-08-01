# frozen_string_literal: true

module RubyJard
  module Layouts
    StandaloneVariablesLayout = RubyJard::Templates::LayoutTemplate.new(
      children: [
        RubyJard::Templates::ScreenTemplate.new(
          height_ratio: 90,
          width_ratio: 100,
          screen: :variables
        )
      ]
    )
  end
end
RubyJard::Layouts.add_layout('standalone-variables', RubyJard::Layouts::StandaloneVariablesLayout)
