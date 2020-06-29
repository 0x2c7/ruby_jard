# frozen_string_literal: true

module RubyJard
  ##
  # Screen registry. The screens call add_screen right after they are declared.
  module Screens
    class << self
      def screen_registry
        @screen_registry ||= {}
      end

      def add_screen(name, screen_class)
        unless screen_class < RubyJard::Screen
          raise RubyJard::Error, "#{screen_class} must implement, and inherit from #{RubyJard::Screen}"
        end

        screen_registry[name] = screen_class
      end

      def [](name)
        screen_registry[name]
      end
      alias get []
    end
  end
end
