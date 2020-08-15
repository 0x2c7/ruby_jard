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
      GREEN      = '71'
      YELLOW     = '136'
      BLUE       = '31'
      PURPLE     = '127'
      CYAN       = '31'

      BACKGROUND = WHITE
      STYLES = {
        background:            [GRAY5, BACKGROUND],
        border:                [GRAY3, BACKGROUND],
        title:                 [WHITE, GREEN],
        title_highlighted:     [WHITE, YELLOW],
        title_secondary:       [GRAY5, GRAY2],
        title_background:      [GRAY3, BACKGROUND],
        menu_mode:             [YELLOW, BACKGROUND],
        menu_tips:             [GRAY4, BACKGROUND],
        thread_id:             [GREEN, BACKGROUND],
        thread_name:           [GRAY5, BACKGROUND],
        thread_status_run:     [GREEN, BACKGROUND],
        thread_status_sleep:   [GRAY4, BACKGROUND],
        thread_status_other:   [GRAY4, BACKGROUND],
        thread_location:       [GRAY5, BACKGROUND],
        frame_id:              [GRAY4, BACKGROUND],
        frame_id_highlighted:  [YELLOW, BACKGROUND],
        frame_location:        [GRAY5, BACKGROUND],
        variable_mark:         [GRAY4, BACKGROUND],
        variable_mark_inline:  [YELLOW, BACKGROUND],
        variable_size:         [GRAY5, BACKGROUND],
        variable_inspection:   [GRAY5, BACKGROUND],
        variable_assignment:   [GRAY5, BACKGROUND],
        source_line_mark:      [YELLOW, BACKGROUND],
        source_lineno:         [GRAY4, BACKGROUND],
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

RubyJard::ColorSchemes.add_color_scheme('256-light', RubyJard::ColorSchemes::X256LightColorScheme)
