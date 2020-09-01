# frozen_string_literal: true

module RubyJard
  module Commands
    ##
    # Helper to dedocrate command output
    module ColorHelpers
      def special(content)
        color_decorator.decorate(:text_special, content)
      end

      def secondary(content)
        color_decorator.decorate(:text_primary, content)
      end

      def highlight(content)
        color_decorator.decorate(:text_highlighted, content)
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
