# frozen_string_literal: true

module RubyJard
  ##
  # A key binding object
  class KeyBinding
    attr_reader :sequence, :action

    def initialize(sequence, action)
      @sequence = sequence
      @action = action
    end
  end
end
