# frozen_string_literal: true

module RubyJard
  ##
  # Layouts registry.
  class Layouts
    class << self
      extend Forwardable
      def_delegators :instance, :fallback_layout, :add_layout, :[], :get, :each

      def instance
        @instance ||= new
      end
    end

    attr_reader :fallback_layout

    def initialize(fallback_layout = RubyJard::Layouts::WideLayout)
      @layout_registry = {}
      @fallback_layout = fallback_layout
    end

    def add_layout(name, layout_class)
      unless layout_class.is_a?(RubyJard::Templates::LayoutTemplate)
        raise RubyJard::Error, "#{layout_class} must be a #{RubyJard::Templates::LayoutTemplate}"
      end

      @layout_registry[name] = layout_class
    end

    def [](name)
      @layout_registry[name.to_s.strip]
    end
    alias_method :get, :[]

    def each(&block)
      @layout_registry.each(&block)
    end
  end
end

# Registering order is also priority when picking layout
require 'ruby_jard/layouts/wide_layout'
require 'ruby_jard/layouts/narrow_vertical_layout'
require 'ruby_jard/layouts/narrow_horizontal_layout'
require 'ruby_jard/layouts/tiny_layout'
