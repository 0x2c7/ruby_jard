# frozen_string_literal: true

module RubyJard
  module ColorSchemes
    class DeepSpaceColorScheme < ColorScheme
      # Shameless copy from https://github.com/tyrannicaltoucan/vim-deep-space/blob/master/colors/deep-space.vim
      GRAY1  = '#1b202a'
      GRAY2  = '#232936'
      GRAY3  = '#323c4d'
      GRAY4  = '#51617d'
      GRAY5  = '#9aa7bd'
      WHITE  = '#fff'
      RED    = '#b15e7c'
      GREEN  = '#96f08d'
      YELLOW = '#e8cb6b'
      BLUE   = '#78b5ff'
      PURPLE = '#b08aed'
      CYAN   = '#56adb7'
      ORANGE = '#f28d5e'
      PINK   = '#c47ebd'

      BACKGROUND = GRAY1
      STYLES = {
        background:                     [WHITE, BACKGROUND],
        screen_border:                  [GRAY3, BACKGROUND],
        screen_title:                   [GRAY2, BLUE],
        screen_title_highlighted:       [GRAY2, ORANGE],
        screen_title_secondary:         [WHITE, GRAY3],
        screen_title_background:        [WHITE, GRAY2],
        control_buttons:                [GRAY4, BACKGROUND],
        thread_id:                      [BLUE, BACKGROUND],
        thread_name:                    [WHITE, BACKGROUND],
        thread_status_run:              [GREEN, BACKGROUND],
        thread_status_sleep:            [GRAY4, BACKGROUND],
        thread_status_other:            [GRAY4, BACKGROUND],
        thread_location:                [GRAY5, BACKGROUND],
        backtrace_frame_id:             [GRAY4, BACKGROUND],
        backtrace_frame_id_highlighted: [GREEN, BACKGROUND],
        backtrace_location:             [GRAY5, BACKGROUND],
        backtrace_class_label:          [BLUE, BACKGROUND],
        backtrace_method_label:         [WHITE, BACKGROUND],
        variable_mark:                  [GRAY4, BACKGROUND],
        variable_mark_inline:           [GREEN, BACKGROUND],
        variable_loc:                   [PURPLE, BACKGROUND],
        variable_ins:                   [PURPLE, BACKGROUND],
        variable_con:                   [ORANGE, BACKGROUND],
        variable_inspection:            [GRAY5, BACKGROUND],
        variable_size:                  [GRAY5, BACKGROUND],
        variable_separator:             [WHITE, BACKGROUND],
        source_line_mark:               [GREEN, BACKGROUND],
        source_lineno:                  [GRAY4, BACKGROUND],
        source_token_keyword:           [BLUE, BACKGROUND],
        source_token_constant:          [ORANGE, BACKGROUND],
        source_token_instance_variable: [PURPLE, BACKGROUND],
        source_token_method:            [YELLOW, BACKGROUND],
        source_token_comment:           [GRAY4, BACKGROUND],
        source_token_literal:           [RED, BACKGROUND],
        source_token_other:             [GRAY5, BACKGROUND]
      }.freeze
    end
  end
end

RubyJard::ColorSchemes.add_color_scheme('deep-space', RubyJard::ColorSchemes::DeepSpaceColorScheme)
