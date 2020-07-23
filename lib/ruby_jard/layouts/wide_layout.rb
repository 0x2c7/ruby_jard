# frozen_string_literal: true

module RubyJard
  module Layouts
    WideLayout = RubyJard::Templates::LayoutTemplate.new(
      min_width: 120,
      min_height: 10,
      width_ratio: 50,
      height_ratio: 80,
      children: [
        RubyJard::Templates::LayoutTemplate.new(
          height_ratio: 80,
          width_ratio: 50,
          min_height: 7,
          fill_width: true,
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
                        margin_right: 1,
                        spans: [
                          RubyJard::Templates::SpanTemplate.new(:type)
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
        RubyJard::Templates::LayoutTemplate.new(
          width_ratio: 50,
          height_ratio: 80,
          fill_width: true,
          fill_height: true,
          children: [
            RubyJard::Templates::ScreenTemplate.new(
              screen: :backtrace,
              height_ratio: 50,
              row_template: RubyJard::Templates::RowTemplate.new(
                columns: [
                  RubyJard::Templates::ColumnTemplate.new(
                    margin_right: 1,
                    spans: [
                      RubyJard::Templates::SpanTemplate.new(:frame_id)
                    ]
                  ),
                  RubyJard::Templates::ColumnTemplate.new(
                    spans: [
                      RubyJard::Templates::SpanTemplate.new(:klass_label, margin_right: 1),
                      RubyJard::Templates::SpanTemplate.new(:label_preposition, margin_right: 1),
                      RubyJard::Templates::SpanTemplate.new(:method_label, margin_right: 1),
                      RubyJard::Templates::SpanTemplate.new(:path)
                    ]
                  )
                ]
              )
            ),
            RubyJard::Templates::ScreenTemplate.new(
              screen: :threads,
              height_ratio: 50,
              row_template: RubyJard::Templates::RowTemplate.new(
                columns: [
                  RubyJard::Templates::ColumnTemplate.new(
                    margin_right: 1,
                    spans: [
                      RubyJard::Templates::SpanTemplate.new(:mark, margin_right: 1),
                      RubyJard::Templates::SpanTemplate.new(:thread_id)
                    ]
                  ),
                  RubyJard::Templates::ColumnTemplate.new(
                    margin_right: 1,
                    spans: [
                      RubyJard::Templates::SpanTemplate.new(:thread_status)
                    ]
                  ),
                  RubyJard::Templates::ColumnTemplate.new(
                    spans: [
                      RubyJard::Templates::SpanTemplate.new(:thread_name, margin_right: 1),
                      RubyJard::Templates::SpanTemplate.new(:thread_location)
                    ]
                  )
                ]
              )
            )
          ]
        ),
        RubyJard::Templates::ScreenTemplate.new(
          height: 3,
          screen: :menu
        )
      ]
    )
  end
end
