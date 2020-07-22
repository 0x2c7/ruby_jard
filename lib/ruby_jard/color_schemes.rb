# frozen_string_literal: true

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
        color_scheme_registry[name]
      end
      alias get []
    end
  end
end
