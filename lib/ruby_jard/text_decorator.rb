# frozen_string_literal: true

module RubyJard
  module Decorators
    class TextDecorator
      attr_reader :length, :content

      def initialize(color, highlighted = false)
        @length = 0
        @content = ''
        @color = color
        @highlighted = highlighted
      end

      def text(sentence, *styles)
        @length += sentence.length

        @content +=
          if styles.empty?
            sentence
          else
            @color.decorate(sentence, *compose_styles(styles))
          end

        self
      end

      def with_highlight(highlighted)
        @highlighted = highlighted

        self
      end

      def +(other)
        if other.is_a?(RubyJard::Decorators::TextDecorator)
          @length = other.length
          @content += other.content
        else
          text(other.to_s)
        end

        self
      end

      private

      def compose_styles(styles)
        styles.delete(:clear)
        styles.delete(:dim)
        styles.prepend(@highlighted ? :clear : :dim)
      end
    end
  end
end
