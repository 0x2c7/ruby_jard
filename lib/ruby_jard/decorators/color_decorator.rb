# frozen_string_literal: true

require 'pastel'

module RubyJard
  module Decorators
    ##
    # Manipulate and decorate color for texts. The core is Pastel, which is a library to
    # inject escape sequences to let the terminal emulator aware of target color. This
    # class wraps around the core, validates, and standardizes the styles before feeding
    # styling information to Pastel.
    class ColorDecorator
      COLORS = [
        :black,
        :red,
        :green,
        :yellow,
        :blue,
        :magenta,
        :cyan,
        :white
      ].freeze

      HEX_PATTERN_6 = /^#([A-Fa-f0-9]{2})([A-Fa-f0-9]{2})([A-Fa-f0-9]{2})$/.freeze
      HEX_PATTERN_3 = /^#([A-Fa-f0-9]{1})([A-Fa-f0-9]{1})([A-Fa-f0-9]{1})$/.freeze

      CSI_RESET = "\e[0m"
      CSI_FOREGROUND_24BIT = "\e[38;2;%d;%d;%dm"
      CSI_BACKGROUND_24BIT = "\e[48;2;%d;%d;%dm"

      CSI_ITALIC = "\e[3m"
      CSI_UNDERLINE = "\e[4m"

      STYLES_CSI_MAP = {
        underline: CSI_UNDERLINE,
        italic: CSI_ITALIC
      }.freeze

      def initialize(color_scheme)
        @pastel = Pastel.new
        @color_scheme = color_scheme
      end

      def decorate(text, *styles)
        styles = standardize_styles(styles)
        @pastel.decorate(text, *styles)
      end

      # TODO: rename and replace #decorate by this method
      def decorate_element(element, content)
        styles = @color_scheme.styles_for(element) || []
        foreground = translate_color(styles.shift, CSI_FOREGROUND_24BIT)
        background = translate_color(styles.shift, CSI_BACKGROUND_24BIT)
        "#{foreground}#{background}#{translate_styles(styles)}#{content}#{CSI_RESET}"
      end

      private

      def translate_color(color, sequence)
        if matches = HEX_PATTERN_6.match(color.to_s)
          red = matches[1].to_i(16)
          green = matches[2].to_i(16)
          blue = matches[3].to_i(16)
          sequence % [red, green, blue]
        elsif matches = HEX_PATTERN_3.match(color.to_s)
          red = (matches[1] * 2).to_i(16)
          green = (matches[2] * 2).to_i(16)
          blue = (matches[3] * 2).to_i(16)
          sequence % [red, green, blue]
        else
          CSI_RESET
        end
      end

      def translate_styles(styles = [])
        styles.map { |key| STYLES_CSI_MAP[key] }.compact.join
      end

      def standardize_styles(styles)
        return [] if styles.include?(:clear)

        if styles.include?(:darker)
          # Convert all bright_color -> color
          styles = darker(styles)
        elsif styles.include?(:brighter)
          # Convert all color -> bright_color
          styles = brighter(styles)
        end

        styles.uniq.compact
      end

      def darker(styles)
        styles.map do |color|
          next if [:darker, :brighter].include?(color)

          color_str = color.to_s
          if color_str.start_with?('bright_')
            color_str.gsub(/^bright_/i, '').to_sym
          else
            color
          end
        end
      end

      def brighter(styles)
        styles.map do |color|
          next if [:darker, :brighter].include?(color)

          color_str = color.to_s
          if color_str.start_with?('bright_')
            color
          elsif COLORS.include?(color)
            "bright_#{color}".to_sym
          else
            color
          end
        end
      end
    end
  end
end
