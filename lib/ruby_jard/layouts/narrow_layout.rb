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
              height_ratio: 60,
              row_template: RubyJard::Templates::RowTemplate.new(
                columns: [
                  RubyJard::Templates::ColumnTemplate.new(
                    margin_right: 1,
                    spans: [
                      RubyJard::Templates::SpanTemplate.new(:mark, margin_right: 1),
                      RubyJard::Templates::SpanTemplate.new(:lineno)
                    ]
                  ),
                  RubyJard::Templates::ColumnTemplate.new(
                    spans: [
                      RubyJard::Templates::SpanTemplate.new(:code)
                    ]
                  )
                ]
              )
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
                  min_height: 3,
                  row_template: RubyJard::Templates::RowTemplate.new(
                    line_limit: 3,
                    columns: [
                      RubyJard::Templates::ColumnTemplate.new(
                        spans: [
                          RubyJard::Templates::SpanTemplate.new(:inline, margin_right: 1)
                        ]
                      ),
                      RubyJard::Templates::ColumnTemplate.new(
                        spans: [
                          RubyJard::Templates::SpanTemplate.new(:name, margin_right: 1),
                          RubyJard::Templates::SpanTemplate.new(:size, margin_right: 1),
                          RubyJard::Templates::SpanTemplate.new(:indicator, margin_right: 1),
                          RubyJard::Templates::SpanTemplate.new(:inspection)
                        ]
                      )
                    ]
                  )
                )
              ]
            )
          ]
        ),
        RubyJard::Templates::ScreenTemplate.new(
          height: 2,
          screen: :menu_narrow
        )
      ]
    )
  end
end
