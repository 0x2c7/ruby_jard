# frozen_string_literal: true

module RubyJard
  module ColorSchemes
    class DeepSpaceColorScheme < ColorScheme
      # Shameless copy from https://github.com/tyrannicaltoucan/vim-deep-space/blob/master/colors/deep-space.vim
      GRAY1      = '#1b202a'
      GRAY2      = '#232936'
      GRAY3      = '#323c4d'
      GRAY4      = '#51617d'
      GRAY5      = '#9aa7bd'
      WHITE      = '#fff'
      RED        = '#b15e7c'
      GREEN      = '#96f08d'
      DARK_GREEN = '#709d6c'
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
        title_highlighted:     [GRAY2, ORANGE],
        title_secondary:       [WHITE, GRAY3],
        title_background:      [WHITE, GRAY2],
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

RubyJard::ColorSchemes.add_color_scheme('deep-space', RubyJard::ColorSchemes::DeepSpaceColorScheme)
