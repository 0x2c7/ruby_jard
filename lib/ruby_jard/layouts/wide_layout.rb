# frozen_string_literal: true

module RubyJard
  module Layouts
    WideLayout = RubyJard::Templates::LayoutTemplate.new(
      min_width: 120,
      min_height: 10,
      fill_width: true,
      fill_height: false,
      children: [
        RubyJard::Templates::LayoutTemplate.new(
          height_ratio: 50,
          min_height: 7,
          fill_width: true,
          children: [
            RubyJard::Templates::ScreenTemplate.new(
              screen: :source,
              width_ratio: 60
            ),
            RubyJard::Templates::LayoutTemplate.new(
              width_ratio: 40,
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
        RubyJard::Templates::LayoutTemplate.new(
          height_ratio: 20,
          min_height: 3,
          fill_width: true,
          children: [
            RubyJard::Templates::ScreenTemplate.new(
              screen: :backtrace,
              width_ratio: 60,
              row_template: RubyJard::Templates::RowTemplate.new(
                columns: [
                  RubyJard::Templates::ColumnTemplate.new(
                    margin_right: 1,
                    spans: [
                      RubyJard::Templates::SpanTemplate.new(
                        :mark,
                        priority: 1
                      ),
                      RubyJard::Templates::SpanTemplate.new(
                        :frame_id,
                        priority: 1
                      )
                    ]
                  ),
                  RubyJard::Templates::ColumnTemplate.new(
                    spans: [
                      RubyJard::Templates::SpanTemplate.new(
                        :klass_label,
                        priority: 0,
                        styles: [:green]
                      ),
                      RubyJard::Templates::SpanTemplate.new(
                        :preposition,
                        priority: 0,
                        styles: [:white],
                        margin_left: 1,
                        margin_right: 1
                      ),
                      RubyJard::Templates::SpanTemplate.new(
                        :method_label,
                        priority: 0,
                        styles: [:green]
                      ),
                      RubyJard::Templates::SpaceTemplate.new,
                      RubyJard::Templates::SpanTemplate.new(
                        :path,
                        priority: 0,
                        styles: [:white],
                        margin_left: 1
                      )
                    ]
                  )
                ]
              )
            ),
            RubyJard::Templates::ScreenTemplate.new(
              screen: :threads,
              width_ratio: 40
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