# frozen_string_literal: true

module RubyJard
  ##
  # This class is an object to store a row of data display on a screen
  class Row
    extend Forwardable

    attr_accessor :columns, :line_limit, :content, :rendered

    def initialize(*columns, line_limit: 1)
      @content = []
      @columns = columns
      @line_limit = line_limit
      @rendered = false
    end

    def spans
      @columns.map(&:spans).flatten
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

  # A row having only one column
  class SimpleRow < Row
    def initialize(*spans)
      super(RubyJard::Column.new, line_limit: 999)

      spans.each { |s| self << s }
    end

    def content_length
      @columns.first.content_length
    end

    def <<(other)
      if other.is_a?(Span)
        @columns.first << other
        return self
      end
      @columns.first << other.spans
      self
    end
  end
end
