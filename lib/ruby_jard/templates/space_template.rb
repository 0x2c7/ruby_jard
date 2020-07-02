# frozen_string_literal: true

module RubyJard
  module Templates
    ##
    # A series of spaces. Used to align or push items in a row.
    class SpaceTemplate
      attr_reader :priority

      def initialize
        @priority = 0
      end
    end
  end
end
