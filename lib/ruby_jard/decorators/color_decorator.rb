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

      def initialize
        @pastel = Pastel.new
      end

      def decorate(text, *styles)
        styles = standardize_styles(styles)
        @pastel.decorate(text, *styles)
      end

      private

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
