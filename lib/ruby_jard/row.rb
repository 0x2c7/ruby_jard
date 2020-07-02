# frozen_string_literal: true

module RubyJard
  class Row
    extend Forwardable

    attr_accessor :row_template, :columns, :height

    def initialize(row_template:, priority:, columns: [])
      @row_template = row_template
      @priority = priority
      @columns = columns
    end
  end
end
