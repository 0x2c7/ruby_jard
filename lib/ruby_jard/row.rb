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

      spans.each do |span|
        self << span
      end
    end

    def content_length
      @columns.first.content_length
    end

    # rubocop:disable Style/CaseLikeIf
    def <<(other)
      if other.is_a?(Span)
        @columns.first << other
      elsif other.is_a?(SimpleRow)
        @columns.first << other.spans
      elsif other.is_a?(Row)
        other.columns.each do |column|
          @columns.first << column.spans
        end
      end

      self
    end
    # rubocop:enable Style/CaseLikeIf
  end
end
