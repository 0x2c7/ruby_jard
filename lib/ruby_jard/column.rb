# frozen_string_literal: true

module RubyJard
  ##
  # This class is an object to contain information of a column in a data drow display on a screen
  class Column
    # Only break at breakable word
    # | this_is_a <endline> |
    # | really_long_content |
    WORD_WRAP_NORMAL = :normal
    # Break the word, and move the rest to the next line
    # | this_is_a really_lon|
    # | g_content           |
    WORD_WRAP_BREAK_WORD = :break_word
    extend Forwardable

    attr_accessor :spans, :content_length, :width, :content_width, :word_wrap

    def initialize(spans: [], width: 0, word_wrap: WORD_WRAP_NORMAL)
      @spans = spans
      @width = width
      @content_length = spans.map(&:content_length).inject(&:+) || 0
      @word_wrap = word_wrap
    end

    def <<(span)
      if span.is_a?(Array)
        span.each { |s| self << s }
      else
        raise RubyJard::Error, 'RubyJard::Span object expected' unless span.is_a?(RubyJard::Span)

        @spans << span
        @content_length += span.content_length
      end

      self
    end
  end
end
