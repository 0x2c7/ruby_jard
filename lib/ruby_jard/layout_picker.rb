# frozen_string_literal: true

module RubyJard
  ##
  # Pick layout smartly depending on current window height and width
  class LayoutPicker
    def initialize(width, height, layouts: RubyJard::Layouts, config: RubyJard.config)
      @width = width
      @height = height
      @layouts = layouts
      @config = config
    end

    def pick
      unless @config.layout.nil?
        return @layouts[@config.layout] || @layouts.fallback_layout
      end

      # RubyJard::Layouts is not a Hash and only implements #each.
      @layouts.each do |_name, template| # rubocop:disable Style/HashEachMethods
        matched = true
        matched &&= template.min_width.nil? ||
                    @width > template.min_width
        matched &&= template.min_height.nil? ||
                    @height > template.min_height
        return template if matched
      end
      @layouts.fallback_layout
    end
  end
end
