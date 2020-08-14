# frozen_string_literal: true

module RubyJard
  module Decorators
    ##
    # Manipulate and decorate color for texts.
    # This class translate colors to corresponding escape sequences.
    # Support 24-bit color (#51617d format) or 256 colors (https://jonasjacek.github.io/colors/)
    # Example:
    # - #fafafa => \e[38;2;250;250;250m
    # - #aaa => \e[38;2;170;170;170m
    # - 77 => \e[38;2;170;170;170m
    class ColorDecorator
      HEX_PATTERN_6 = /^#([A-Fa-f0-9]{2})([A-Fa-f0-9]{2})([A-Fa-f0-9]{2})$/i.freeze
      HEX_PATTERN_3 = /^#([A-Fa-f0-9]{1})([A-Fa-f0-9]{1})([A-Fa-f0-9]{1})$/i.freeze
      XTERM_NUMBER_PATTERN = /^([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])$/i.freeze

      CSI_RESET = "\e[0m"
      CSI_FOREGROUND_24BIT = "\e[38;2;%d;%d;%dm"
      CSI_BACKGROUND_24BIT = "\e[48;2;%d;%d;%dm"
      CSI_FOREGROUND_256 = "\e[38;5;%dm"
      CSI_BACKGROUND_256 = "\e[48;5;%dm"

      CSI_ITALIC = "\e[3m"
      CSI_UNDERLINE = "\e[4m"

      STYLES_CSI_MAP = {
        underline: CSI_UNDERLINE,
        italic: CSI_ITALIC
      }.freeze

      def initialize(color_scheme)
        @color_scheme = color_scheme
      end

      # TODO: rename and replace #decorate by this method
      def decorate(element, content)
        styles = @color_scheme.styles_for(element) || []
        foreground = translate_color(styles.shift, true)
        background = translate_color(styles.shift, false)
        "#{foreground}#{background}#{translate_styles(styles)}#{content}#{CSI_RESET}"
      end

      def translate_color(color, foreground)
        if (matches = HEX_PATTERN_6.match(color.to_s))
          red = matches[1].to_i(16)
          green = matches[2].to_i(16)
          blue = matches[3].to_i(16)
          sequence = foreground ? CSI_FOREGROUND_24BIT : CSI_BACKGROUND_24BIT
          format sequence, red, green, blue
        elsif (matches = HEX_PATTERN_3.match(color.to_s))
          red = (matches[1] * 2).to_i(16)
          green = (matches[2] * 2).to_i(16)
          blue = (matches[3] * 2).to_i(16)
          sequence = foreground ? CSI_FOREGROUND_24BIT : CSI_BACKGROUND_24BIT
          format sequence, red, green, blue
        elsif (matches = XTERM_NUMBER_PATTERN.match(color.to_s))
          color = matches[1]
          sequence = foreground ? CSI_FOREGROUND_256 : CSI_BACKGROUND_256
          format sequence, color
        else
          ''
        end
      end

      private

      def translate_styles(styles = [])
        styles.map { |key| STYLES_CSI_MAP[key] }.compact.join
      end
    end
  end
end
