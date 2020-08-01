# frozen_string_literal: true

module RubyJard
  module ColorSchemes
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
      DARK_GREEN = '#98971a'
      YELLOW     = '#fabd2f'
      BLUE       = '#83a598'
      PURPLE     = '#d3869b'
      CYAN       = '#8ec07c'
      ORANGE     = '#fe8019'

      BACKGROUND = GRAY1
      STYLES = {
        background:            [WHITE, BACKGROUND],
        border:                [GRAY3, BACKGROUND],
        title:                 [GRAY2, BLUE],
        title_highlighted:     [GRAY2, ORANGE],
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

RubyJard::ColorSchemes.add_color_scheme('gruvbox', RubyJard::ColorSchemes::GruvboxColorScheme)
