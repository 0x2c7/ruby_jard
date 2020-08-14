# frozen_string_literal: true

require 'ruby_jard/color_scheme'

module RubyJard
  ##
  # Color scheme registry.
  module ColorSchemes
    class << self
      def color_scheme_registry
        @color_scheme_registry ||= {}
      end

      def add_color_scheme(name, color_scheme_class)
        unless color_scheme_class < RubyJard::ColorScheme
          raise RubyJard::Error, "#{color_scheme_class} must implement, and inherit from #{RubyJard::ColorScheme}"
        end

        color_scheme_registry[name] = color_scheme_class
      end

      def [](name)
        color_scheme_registry[name.to_s.strip]
      end
      alias_method :get, :[]

      def names
        color_scheme_registry.keys.sort.dup
      end
    end
  end
end

require 'ruby_jard/color_schemes/deep_space_color_scheme'
require 'ruby_jard/color_schemes/256_color_scheme'
require 'ruby_jard/color_schemes/gruvbox_color_scheme'
