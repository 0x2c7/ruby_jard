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

    def initialize(spans: [], word_wrap: WORD_WRAP_NORMAL)
      @spans = spans
      @width = 0
      @content_length = 0
      @word_wrap = word_wrap
    end
  end
end
