module RubyJard
  LayoutTemplate = Struct.new(
    :screen,
    :height_ratio, :width_ratio,
    :min_width, :min_height,
    :height, :width,
    :children,
    :fill_width, :fill_height,
    keyword_init: true
  )

  WideLayoutTemplate = LayoutTemplate.new(
    min_width: 120,
    min_height: 10,
    fill_width: true,
    fill_height: false,
    children: [
      LayoutTemplate.new(
        height_ratio: 20,
        min_height: 3,
        fill_width: true,
        children: [
          LayoutTemplate.new(
            screen: :stacktraces,
            width_ratio: 50
          ),
          LayoutTemplate.new(
            screen: :threads,
            width_ratio: 50
          )
        ]
      ),
      LayoutTemplate.new(
        height_ratio: 50,
        min_height: 7,
        fill_width: true,
        children: [
          LayoutTemplate.new(
            screen: :source,
            width_ratio: 50
          ),
          LayoutTemplate.new(
            width_ratio: 50,
            fill_height: true,
            children: [
              LayoutTemplate.new(
                screen: :breakpoints,
                width_ratio: 100,
                height_ratio: 33,
                min_height: 3
              ),
              LayoutTemplate.new(
                screen: :variables,
                width_ratio: 100,
                height_ratio: 33,
                min_height: 3
              ),
              LayoutTemplate.new(
                screen: :expressions,
                width_ratio: 100,
                height_ratio: 33,
                min_height: 3
              )
            ]
          )
        ]
      ),
      LayoutTemplate.new(
        height: 1,
        screen: :menu
      )
    ]
  )

  DEFAULT_LAYOUT_TEMPLATES = [
    WideLayoutTemplate
  ].freeze
end
