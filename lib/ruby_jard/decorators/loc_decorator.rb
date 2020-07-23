# frozen_string_literal: true

require 'coderay'

module RubyJard
  module Decorators
    ##
    # Decorate a line of code fetched from the source file.
    # The line is tokenized, and feed into JardEncoder to append color (with
    # Span).
    class LocDecorator
      attr_reader :spans, :tokens

      def initialize(file, loc)
        @file = file
        @loc = loc
        @encoder = JardLocEncoder.new

        decorate
      end

      def decorate
        @tokens = CodeRay.scan(@loc, extension)
        @spans = @encoder.encode_tokens(tokens)
      end

      private

      def extension
        # TODO: A map constant is better
        if @file =~ /.*\.erb$/
          :erb
        elsif @file =~ /.*\.haml$/
          :haml
        else
          :ruby
        end
      end

      # A shameless copy from https://github.com/rubychan/coderay/blob/master/lib/coderay/encoders/terminal.rb
      class JardLocEncoder < CodeRay::Encoders::Encoder
        DEFAULT_STYLE = :other
        TOKEN_STYLES = {
          annotation: :keyword,
          attribute_name: :keyword,
          attribute_value: :keyword,
          binary: {
            self: :keyword,
            char: :keyword,
            delimiter: :keyword
          },
          char: {
            self: :keyword,
            delimiter: :keyword
          },
          class: :constant,
          class_variable: :constant,
          color: :constant,
          comment: {
            self: :comment,
            char: :comment,
            delimiter: :comment
          },
          constant: :constant,
          decorator: :keyword,
          definition: :keyword,
          directive: :keyword,
          docstring: :keyword,
          doctype: :keyword,
          done: :keyword,
          entity: :keyword,
          error: :constant,
          exception: :keyword,
          float: :keyword,
          function: :constant,
          method: :method,
          global_variable: :constant,
          hex: :keyword,
          id: :keyword,
          include: :keyword,
          integer: :literal,
          imaginary: :keyword,
          important: :keyword,
          key: {
            self: :literal,
            char: :literal,
            delimiter: :literal
          },
          label: :literal,
          local_variable: :keyword,
          namespace: :keyword,
          octal: :keyword,
          predefined: :keyword,
          predefined_constant: :keyword,
          predefined_type: :constant,
          preprocessor: :keyword,
          pseudo_class: :keyword,
          regexp: {
            self: :keyword,
            delimiter: :keyword,
            modifier: :keyword,
            char: :keyword
          },
          reserved: :keyword,
          keyword: :keyword,
          shell: {
            self: :keyword,
            char: :keyword,
            delimiter: :keyword,
            escape: :keyword
          },
          string: {
            self: :keyword,
            modifier: :keyword,
            char: :keyword,
            delimiter: :keyword,
            escape: :keyword
          },
          symbol: {
            self: :literal,
            delimiter: :literal
          },
          tag: :constant,
          type: :keyword,
          value: :keyword,
          variable: :keyword,
          instance_variable: :instance_variable
        }.freeze

        protected

        def setup(options)
          super
          @opened = []
          @color_scopes = [TOKEN_STYLES]
          @out = []
        end

        public

        def text_token(text, kind)
          color = @color_scopes.last[kind]
          text.gsub!("\n", '')
          style =
            if !color
              DEFAULT_STYLE
            elsif color.is_a? Hash
              color[:self]
            else
              color
            end
          @out << Span.new(
            span_template: nil,
            # content: "#{text}(#{kind})",
            content: text,
            content_length: text.length,
            styles: { element: "source_token_#{style}".to_sym }
          )
        end

        def begin_group(kind)
          @opened << kind
          open_token(kind)
        end
        alias begin_line begin_group

        def end_group(_kind)
          return unless @opened.pop

          @color_scopes.pop
        end

        def end_line(kind)
          end_group(kind)
        end

        private

        def open_token(kind)
          color = @color_scopes.last[kind]
          @color_scopes <<
            if color
              if color.is_a?(Hash)
                color
              else
                @color_scopes.last
              end
            else
              @color_scopes.last
            end
        end
      end
    end
  end
end
