# frozen_string_literal: true

module RubyJard
  ##
  # Smallest unit of texts. A span includes content, margin, and styles of a particular
  # text chunk. All decorators and presenters return single/a list of spans.
  class Span
    extend Forwardable

    attr_accessor :content, :content_length, :styles

    def initialize(content: '', content_length: nil, margin_left: 0, margin_right: 0, styles: [])
      if !content.nil? && !content.empty?
        content = ' ' * margin_left + content if margin_left > 0
        content += ' ' * margin_right if margin_right > 0
      end

      @content = content.to_s
      @content_length = content_length || @content.length
      @styles = styles
    end
  end
end
