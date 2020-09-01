# frozen_string_literal: true

module RubyJard
  class ColorSchemes
    class GruvboxColorScheme < ColorScheme
      # Shameless copy from https://github.com/morhetz/gruvbox
      GRAY1      = '#282828'
      GRAY2      = '#3c3836'
      GRAY3      = '#504945'
      GRAY4      = '#d5c4a1'
      GRAY5      = '#ebdbb2'
      WHITE      = '#f9f5d7'
      RED        = '#fb4934'
      GREEN      = '#b8bb26'
      YELLOW     = '#fabd2f'
      BLUE       = '#83a598'
      PURPLE     = '#d3869b'
      CYAN       = '#8ec07c'
      ORANGE     = '#fe8019'

      BACKGROUND = GRAY1
      STYLES = {
        background:        [WHITE, BACKGROUND],
        border:            [GRAY3, BACKGROUND],
        title:             [GRAY2, BLUE],
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

RubyJard::ColorSchemes.add_color_scheme('gruvbox', RubyJard::ColorSchemes::GruvboxColorScheme)
