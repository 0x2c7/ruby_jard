# frozen_string_literal: true

module RubyJard
  ##
  # Smallest unit of texts. A span includes content, margin, and styles of a particular
  # text chunk. All decorators and presenters return single/a list of spans.
  class Span
    # DSL to simplify span creation
    module DSL
      def text_primary(content)
        Span.new(content: content, styles: :text_primary)
      end

      def text_dim(content)
        Span.new(content: content, styles: :text_dim)
      end

      def text_selected(content)
        Span.new(content: content, styles: :text_selected)
      end

      def text_special(content)
        Span.new(content: content, styles: :text_special)
      end

      def text_highlighted(content)
        Span.new(content: content, styles: :text_highlighted)
      end

      def text_constant(content)
        Span.new(content: content, styles: :constant)
      end

      def text_method(content)
        Span.new(content: content, styles: :method)
      end

      def text_string(content)
        Span.new(content: content, styles: :string)
      end

      def sym_arrow(styles: :text_highlighted)
        Span.new(content: ' → ', styles: styles)
      end

      def sym_ellipsis(styles: :text_dim)
        Span.new(content: '…', styles: styles)
      end

      def sym_bullet(styles: :text_dim)
        Span.new(content: '  ▸ ', styles: styles)
      end
    end

    extend Forwardable

    attr_accessor :content, :content_length, :styles

    def initialize(content: '', content_length: nil, styles: [])
      @content = content
      @content = content.to_s.gsub(/\r\n/, '\n').gsub(/\n/, '\n') if content.include?("\n")
      @content_length = content_length || @content.length
      @styles = styles
    end
  end
end
