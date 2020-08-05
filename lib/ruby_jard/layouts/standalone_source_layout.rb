# frozen_string_literal: true

module RubyJard
  module Layouts
    StandaloneSourceLayout = RubyJard::Templates::LayoutTemplate.new(
      children: [
        RubyJard::Templates::ScreenTemplate.new(
          height_ratio: 90,
          width_ratio: 100,
          screen: :source
        )
      ]
    )
  end
end
RubyJard::Layouts.add_layout('standalone-source', RubyJard::Layouts::StandaloneSourceLayout)
