# frozen_string_literal: true

module RubyJard
  module Screens
    class EmptyScreen < RubyJard::Screen
      def draw
        # Do nothing
      end
    end
  end
end

RubyJard::Screens.add_screen(:empty, RubyJard::Screens::EmptyScreen)
