# frozen_string_literal: true

module RubyJard
  module ColorSchemes
    class X256ColorScheme < ColorScheme
      # Basic 256 colors that nearly all terminal supports. Just for backward-compatibility
      # https://en.wikipedia.org/wiki/ANSI_escape_code
      GRAY1      = '234'
      GRAY2      = '238'
      GRAY3      = '241'
      GRAY4      = '245'
      GRAY5      = '249'
      WHITE      = '15'
      RED        = '167'
      GREEN      = '40'
      DARK_GREEN = '34'
      YELLOW     = '184'
      BLUE       = '75'
      PURPLE     = '177'
      CYAN       = '50'
      ORANGE     = '208'
      PINK       = '206'

      BACKGROUND = nil
      STYLES = {
        background:            [WHITE, BACKGROUND],
        border:                [GRAY2, BACKGROUND],
        title:                 [GRAY1, BLUE],
        title_highlighted:     [GRAY1, ORANGE],
        title_secondary:       [WHITE, GRAY3],
        title_background:      [GRAY2, GRAY2],
        menu_mode:             [ORANGE, BACKGROUND],
        menu_tips:             [GRAY4, BACKGROUND],
        thread_id:             [BLUE, BACKGROUND],
        thread_name:           [WHITE, BACKGROUND],
        thread_status_run:     [GREEN, BACKGROUND],
        thread_status_sleep:   [GRAY4, BACKGROUND],
        thread_status_other:   [GRAY4, BACKGROUND],
        thread_location:       [GRAY5, BACKGROUND],
        frame_id:              [GRAY4, BACKGROUND],
        frame_id_highlighted:  [GREEN, BACKGROUND],
        frame_location:        [GRAY5, BACKGROUND],
        variable_mark:         [GRAY4, BACKGROUND],
        variable_mark_inline:  [GREEN, BACKGROUND],
        variable_size:         [GRAY5, BACKGROUND],
        variable_inspection:   [GRAY4, BACKGROUND],
        variable_assignment:   [WHITE, BACKGROUND],
        source_line_mark:      [GREEN, BACKGROUND],
        source_lineno:         [GRAY4, BACKGROUND],
        keyword:               [BLUE, BACKGROUND],
        method:                [YELLOW, BACKGROUND],
        comment:               [GRAY4, BACKGROUND],
        literal:               [RED, BACKGROUND],
        string:                [DARK_GREEN, BACKGROUND],
        local_variable:        [PURPLE, BACKGROUND],
        instance_variable:     [PURPLE, BACKGROUND],
        constant:              [BLUE, BACKGROUND],
        normal_token:          [GRAY5, BACKGROUND],
        object:                [CYAN, BACKGROUND]
      }.freeze
    end
  end
end

RubyJard::ColorSchemes.add_color_scheme('256', RubyJard::ColorSchemes::X256ColorScheme)
