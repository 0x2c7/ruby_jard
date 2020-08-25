# frozen_string_literal: true

module RubyJard
  class ColorSchemes
    class DeepSpaceColorScheme < ColorScheme
      # Shameless copy from https://github.com/tyrannicaltoucan/vim-deep-space/blob/master/colors/deep-space.vim
      GRAY1      = '#1b202a'
      GRAY2      = '#232936'
      GRAY3      = '#323c4d'
      GRAY4      = '#51617d'
      GRAY5      = '#9aa7bd'
      WHITE      = '#fff'
      RED        = '#b15e7c'
      GREEN      = '#80b57b'
      YELLOW     = '#e8cb6b'
      BLUE       = '#78b5ff'
      PURPLE     = '#b08aed'
      CYAN       = '#56adb7'
      ORANGE     = '#f28d5e'
      PINK       = '#c47ebd'

      BACKGROUND = GRAY1
      STYLES = {
        background:            [WHITE, BACKGROUND],
        border:                [GRAY3, BACKGROUND],
        title:                 [GRAY2, BLUE],
        title_secondary:       [WHITE, GRAY3],
        title_background:      [GRAY2, GRAY2],
        text_primary:          [WHITE, BACKGROUND],
        text_secondary:        [GRAY5, BACKGROUND],
        text_dim:              [GRAY4, BACKGROUND],
        text_highlighted:      [BLUE, BACKGROUND],
        text_special:          [ORANGE, BACKGROUND],
        text_selected:         [GREEN, BACKGROUND],
        keyword:               [BLUE, BACKGROUND],
        method:                [YELLOW, BACKGROUND],
        comment:               [GRAY4, BACKGROUND],
        literal:               [RED, BACKGROUND],
        string:                [GREEN, BACKGROUND],
        local_variable:        [PURPLE, BACKGROUND],
        instance_variable:     [PURPLE, BACKGROUND],
        constant:              [BLUE, BACKGROUND],
        normal_token:          [GRAY5, BACKGROUND],
        object:                [CYAN, BACKGROUND]
      }.freeze
    end
  end
end

RubyJard::ColorSchemes.add_color_scheme('deep-space', RubyJard::ColorSchemes::DeepSpaceColorScheme)
