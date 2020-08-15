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

RubyJard::ColorSchemes.add_color_scheme('one-half-light', RubyJard::ColorSchemes::OneHalfLightColorScheme)
