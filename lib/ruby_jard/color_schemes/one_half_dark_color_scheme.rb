# frozen_string_literal: true

module RubyJard
  class ColorSchemes
    class OneHalfDarkColorScheme < ColorScheme
      # Shameless copy from https://github.com/sonph/onehalf/blob/master/vim/colors/onehalfdark.vim
      GRAY1      = '#282c34'
      GRAY2      = '#313640'
      GRAY3      = '#5c6370'
      GRAY4      = '#dcdfe4'
      GRAY5      = '#dcdfe4'
      WHITE      = '#dcdfe4'
      RED        = '#e06c75'
      GREEN      = '#98c379'
      YELLOW     = '#e5c07b'
      BLUE       = '#61afef'
      PURPLE     = '#c678dd'
      CYAN       = '#56b6c2'

      BACKGROUND = GRAY1
      STYLES = {
        background:            [WHITE, BACKGROUND],
        border:                [GRAY3, BACKGROUND],
        title:                 [GRAY2, GREEN],
        title_secondary:       [WHITE, GRAY3],
        title_background:      [GRAY2, GRAY2],
        text_primary:          [WHITE, BACKGROUND],
        text_secondary:        [GRAY5, BACKGROUND],
        text_dim:              [GRAY4, BACKGROUND],
        text_highlighted:      [GREEN, BACKGROUND],
        text_special:          [GREEN, BACKGROUND],
        text_selected:         [YELLOW, BACKGROUND],
        keyword:               [PURPLE, BACKGROUND],
        method:                [BLUE, BACKGROUND],
        comment:               [GRAY4, BACKGROUND],
        literal:               [YELLOW, BACKGROUND],
        string:                [GREEN, BACKGROUND],
        local_variable:        [RED, BACKGROUND],
        instance_variable:     [RED, BACKGROUND],
        constant:              [YELLOW, BACKGROUND],
        normal_token:          [GRAY5, BACKGROUND],
        object:                [YELLOW, BACKGROUND]
      }.freeze
    end
  end
end

RubyJard::ColorSchemes.add_color_scheme('one-half-dark', RubyJard::ColorSchemes::OneHalfDarkColorScheme)
