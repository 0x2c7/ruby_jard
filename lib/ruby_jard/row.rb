# frozen_string_literal: true

module RubyJard
  class Row
    extend Forwardable

    attr_accessor :columns, :line_limit, :content

    def initialize(line_limit: 1, columns: [], ellipsis: true)
      @content = []
      @columns = columns
      @ellipsis = ellipsis
      @line_limit = line_limit
    end
  end
end
