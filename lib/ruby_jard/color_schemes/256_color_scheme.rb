# frozen_string_literal: true

module RubyJard
  class ColorSchemes
    class X256ColorScheme < ColorScheme
      # Basic 256 colors that nearly all terminal supports. Just for backward-compatibility
      # https://en.wikipedia.org/wiki/ANSI_escape_code
      GRAY1      = '234'
      GRAY2      = '237'
      GRAY3      = '239'
      GRAY4      = '245'
      GRAY5      = '249'
      WHITE      = '15'
      RED        = '167'
      GREEN      = '42'
      YELLOW     = '184'
      BLUE       = '75'
      PURPLE     = '177'
      CYAN       = '50'
      ORANGE     = '208'
      PINK       = '206'

      BACKGROUND = nil
      STYLES = {
        background:        [WHITE, BACKGROUND],
        border:            [GRAY2, BACKGROUND],
        title:             [GRAY1, BLUE],
        title_secondary:   [WHITE, GRAY3],
        title_background:  [GRAY2, GRAY2],
        text_primary:      [GRAY5, BACKGROUND],
        text_dim:          [GRAY4, BACKGROUND],
        text_highlighted:  [BLUE, BACKGROUND],
        text_special:      [ORANGE, BACKGROUND],
        text_selected:     [GREEN, BACKGROUND],
        keyword:           [BLUE, BACKGROUND],
        method:            [YELLOW, BACKGROUND],
        comment:           [GRAY4, BACKGROUND],
        literal:           [RED, BACKGROUND],
        string:            [GREEN, BACKGROUND],
        local_variable:    [PURPLE, BACKGROUND],
        instance_variable: [PURPLE, BACKGROUND],
        constant:          [BLUE, BACKGROUND],
        normal_token:      [GRAY5, BACKGROUND],
        object:            [CYAN, BACKGROUND]
      }.freeze
    end
  end
end

RubyJard::ColorSchemes.add_color_scheme('256', RubyJard::ColorSchemes::X256ColorScheme)
