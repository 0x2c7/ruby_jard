# frozen_string_literal: true

module RubyJard
  class ColorSchemes
    class OneHalfLightColorScheme < ColorScheme
      # Shameless copy from https://github.com/sonph/onehalf/blob/master/vim/colors/onehalflight.vim
      GRAY1      = '#eaeaea'
      GRAY2      = '#d4d4d4'
      GRAY3      = '#a0a1a7'
      GRAY4      = '#a0a1a7'
      GRAY5      = '#383a42'

      WHITE      = '#fafafa'
      RED        = '#e45649'
      GREEN      = '#50a14f'
      YELLOW     = '#c18401'
      BLUE       = '#0184bc'
      PURPLE     = '#a626a4'
      CYAN       = '#0997b3'

      BACKGROUND = WHITE
      STYLES = {
        background:        [GRAY5, BACKGROUND],
        border:            [GRAY3, BACKGROUND],
        title:             [WHITE, GREEN],
        title_secondary:   [GRAY5, GRAY2],
        title_background:  [GRAY3, BACKGROUND],
        text_primary:      [GRAY5, BACKGROUND],
        text_dim:          [GRAY4, BACKGROUND],
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

RubyJard::ColorSchemes.add_color_scheme('one-half-light', RubyJard::ColorSchemes::OneHalfLightColorScheme)
