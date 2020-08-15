# frozen_string_literal: true

require 'ruby_jard/screen'

module RubyJard
  ##
  # Screen registry. The screens call add_screen right after they are declared.
  class Screens
    class << self
      extend Forwardable
      def_delegators :instance, :add_screen, :[], :get, :names

      def instance
        @instance ||= new
      end
    end

    def initialize
      @screen_registry = {}
    end

    def add_screen(name, screen_class)
      unless screen_class < RubyJard::Screen
        raise RubyJard::Error, "#{screen_class} must implement, and inherit from #{RubyJard::Screen}"
      end

      @screen_registry[name.to_s] = screen_class
    end

    def [](name)
      @screen_registry[name.to_s]
    end
    alias_method :get, :[]

    def names
      @screen_registry.keys.sort.dup
    end
  end
end

require 'ruby_jard/screens/source_screen'
require 'ruby_jard/screens/backtrace_screen'
require 'ruby_jard/screens/threads_screen'
require 'ruby_jard/screens/variables_screen'
require 'ruby_jard/screens/menu_screen'
