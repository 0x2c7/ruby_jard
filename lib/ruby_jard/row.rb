# frozen_string_literal: true

module RubyJard
  ##
  # This class is an object to store a row of data display on a screen
  class Row
    extend Forwardable

    attr_accessor :columns, :line_limit, :content, :rendered

    def initialize(line_limit: 1, columns: [], ellipsis: true)
      @content = []
      @columns = columns
      @ellipsis = ellipsis
      @line_limit = line_limit
      @rendered = false
    end

    def rendered?
      @rendered == true
    end

    def mark_rendered
      @rendered = true
    end

    def reset_rendered
      @rendered = false
    end
  end
end
