# frozen_string_literal: true

module RubyJard
  module Commands
    ##
    # Helper to dedocrate command output
    module ColorHelpers
      def highlight(content)
        "\e[33m#{content}\e[0m"
      end

      def pick_color_scheme
        (
          RubyJard::ColorSchemes[RubyJard.config.color_scheme] ||
          RubyJard::ColorSchemes[RubyJard::Config::DEFAULT_COLOR_SCHEME]
        ).new
      end

      def color_decorator
        @color_decorator ||= RubyJard::Decorators::ColorDecorator.new(pick_color_scheme)
      end
    end
  end
end
