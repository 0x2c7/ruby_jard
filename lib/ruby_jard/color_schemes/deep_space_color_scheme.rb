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
      RED    = '#b15e7c'
      GREEN  = '#709d6c'
      YELLOW = '#b5a262'
      BLUE   = '#608cc3'
      PURPLE = '#8f72bf'
      CYAN   = '#56adb7'
      ORANGE = '#b3785d'
      PINK   = '#c47ebd'

      BACKGROUND = GRAY1
      STYLES = {
        background:               [GRAY5, BACKGROUND],
        screen_border:            [GRAY3, BACKGROUND],
        screen_title:             [GRAY2, BLUE],
        screen_title_highlighted: [GRAY2, ORANGE],
        screen_title_secondary:   [GRAY5, GRAY3],
        screen_title_background:  [GRAY5, GRAY2],
        control_buttons:          [GRAY4, BACKGROUND],
        thread_id:                [BLUE, BACKGROUND],
        thread_name:              [GRAY5, BACKGROUND],
        thread_status_run:        [GREEN, BACKGROUND],
        thread_status_sleep:      [GRAY4, BACKGROUND],
        thread_status_other:      [GRAY4, BACKGROUND],
        thread_location:          [GRAY4, BACKGROUND]
      }.freeze
    end
  end
end

RubyJard::ColorSchemes.add_color_scheme('deep-space', RubyJard::ColorSchemes::DeepSpaceColorScheme)
