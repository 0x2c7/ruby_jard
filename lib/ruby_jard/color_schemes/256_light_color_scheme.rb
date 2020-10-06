# frozen_string_literal: true

module RubyJard
  class ColorSchemes
    class X256LightColorScheme < ColorScheme
      # Shameless copy from https://github.com/sonph/onehalf/blob/master/vim/colors/onehalflight.vim
      GRAY1      = '237'
      GRAY2      = '252'
      GRAY3      = '247'
      GRAY4      = '247'
      GRAY5      = '237'

      WHITE      = '231'
      RED        = '167'
      GREEN      = '22'
      YELLOW     = '136'
      BLUE       = '31'
      PURPLE     = '127'
      CYAN       = '31'

      BACKGROUND = WHITE
      STYLES = {
        background:        [GRAY5, BACKGROUND],
        border:            [GRAY3, BACKGROUND],
        title:             [WHITE, GREEN],
        title_secondary:   [GRAY5, GRAY2],
        title_background:  [GRAY3, BACKGROUND],
        text_primary:      [GRAY5, BACKGROUND],
        text_dim:          [GRAY5, BACKGROUND],
        text_highlighted:  [BLUE, BACKGROUND],
        text_special:      [RED, BACKGROUND],
        text_selected:     [GREEN, BACKGROUND],
        keyword:           [PURPLE, BACKGROUND],
        method:            [BLUE, BACKGROUND],
        comment:           [GRAY4, BACKGROUND],
        literal:           [YELLOW, BACKGROUND],
        string:            [GREEN, BACKGROUND],
        local_variable:    [RED, BACKGROUND],
        instance_variable: [RED, BACKGROUND],
        constant:          [YELLOW, BACKGROUND],
        normal_token:      [GRAY5, BACKGROUND],
        object:            [YELLOW, BACKGROUND]
      }.freeze
    end
  end
end

RubyJard::ColorSchemes.add_color_scheme('256-light', RubyJard::ColorSchemes::X256LightColorScheme)
