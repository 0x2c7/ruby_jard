# frozen_string_literal: true

module RubyJard
  ##
  # A helper class to store pre-defined keys and key bindings
  class Keys
    # X-Term: https://invisible-island.net/xterm/xterm-function-keys.html
    END_LINE = ["\n", "\r\n", "\r"].freeze
    CTRL_C = "\u0003"
    CTRL_D = "\u0004"

    F1 = "\eOP"
    F2 = "\eOQ"
    F3 = "\eOR"
    F4 = "\eOS"
    F5 = "\e[15~"
    F6 = "\e[17~"
    F7 = "\e[18~"
    F8 = "\e[19~"
    F9 = "\e[20~"
    F10 = "\e[21~"
    F11 = "\e[23~"
    F12 = "\e[24~"

    SHIFT_F1 = "\e1;2P"
    SHIFT_F2 = "\e1;2Q"
    SHIFT_F3 = "\e1;2R"
    SHIFT_F4 = "\e1;2S"
    SHIFT_F5 = "\e[15;2~"
    SHIFT_F6 = "\e[17;2~"
    SHIFT_F7 = "\e[18;2~"
    SHIFT_F8 = "\e[19;2~"
    SHIFT_F9 = "\e[20;2~"
    SHIFT_F10 = "\e[21;2~"
    SHIFT_F11 = "\e[23;2~"
    SHIFT_F12 = "\e[24;2~"

    # rubocop:disable Layout/HashAlignment
    DEFAULT_KEY_BINDINGS = {
      F6       => (ACTION_UP       = :up),
      SHIFT_F6 => (ACTION_DOWN     = :down),
      F7       => (ACTION_STEP     = :step),
      SHIFT_F7 => (ACTION_STEP_OUT = :step_out),
      F8       => (ACTION_NEXT     = :next),
      F9       => (ACTION_CONTINUE = :continue)
    }.freeze
    # rubocop:enable Layout/HashAlignment
  end
end
