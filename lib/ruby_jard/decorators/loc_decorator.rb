module RubyJard
  module Decorators
    class LocDecorator
      attr_reader :loc, :tokens

      def initialize(color_decorator, loc)
        @loc = loc
        @encoder = JardLocEncoder.new(
          color_decorator: color_decorator
        )

        decorate
      end

      def decorate
        @tokens = CodeRay.scan(@loc, :ruby)
        @loc = @encoder.encode_tokens(tokens)
      end

      # A shameless copy from https://github.com/rubychan/coderay/blob/master/lib/coderay/encoders/terminal.rb
      class JardLocEncoder < CodeRay::Encoders::Encoder
        TOKEN_COLORS = {
          debug: [:white, :on_blue],
          annotation: [:blue],
          attribute_name: [:red],
          attribute_value: [:red],
          binary: {
            self: [:red],
            char: [:red],
            delimiter: [:red]
          },
          char: {
            self: [:red],
            delimiter: [:red]
          },
          class: [:green],
          class_variable: [:cyan],
          color: [:green],
          comment: {
            self: [:white],
            char: [:white],
            delimiter: [:white]
          },
          constant: [:green],
          decorator: [:red],
          definition: [:yellow],
          directive: [:yellow],
          docstring: [:red],
          doctype: [:blue],
          done: [:blue],
          entity: [:red],
          error: [:white, :on_red],
          exception: [:red],
          float: [:red],
          function: [:green],
          method: [:yellow],
          global_variable: [:green],
          hex: [:cyan],
          id: [:blue],
          include: [:red],
          integer: [:red],
          imaginary: [:blue],
          important: [:red],
          key: {
            self: [:red],
            char: [:red],
            delimiter: [:red]
          },
          label: [:yellow],
          local_variable: [:yellow],
          namespace: [:red],
          octal: [:blue],
          predefined: [:cyan],
          predefined_constant: [:cyan],
          predefined_type: [:green],
          preprocessor: [:cyan],
          pseudo_class: [:blue],
          regexp: {
            self: [:red],
            delimiter: [:red],
            modifier: [:red],
            char: [:red]
          },
          reserved: [:blue],
          keyword: [:blue],
          shell: {
            self: [:yellow],
            char: [:yellow],
            delimiter: [:yellow],
            escape: [:yellow]
          },
          string: {
            self: [:red],
            modifier: [:red],
            char: [:red],
            delimiter: [:red],
            escape: [:red]
          },
          symbol: {
            self: [:yellow],
            delimiter: [:yellow]
          },
          tag: [:green],
          type: [:blue],
          value: [:cyan],
          variable: [:blue],
          insert: {
            self: [:on_green],
            insert: [:green, :on_green],
            eyecatcher: [:italic]
          },
          delete: {
            self: [:on_red],
            delete: [:red, :on_red],
            eyecatcher: [:italic]
          },
          change: {
            self: [:on_blue],
            change: [:white, :on_blue]
          },
          head: {
            self: [:on_red],
            filename: [:white, :on_red]
          }
        }.freeze

        protected

        def setup(options)
          super
          @opened = []
          @color_scopes = [TOKEN_COLORS]
          @color_decorator = options[:color_decorator]
        end

        public

        def text_token(text, kind)
          color = @color_scopes.last[kind]
          if color
            color = color[:self] if color.is_a? Hash
            @out << @color_decorator.decorate(text, *color)
            # @out << " [#{text} - #{kind} (#{compose_color(color)})]"
          else
            @out << @color_decorator.decorate(text, :clear)
          end
          a = 1
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
          @out << (@line_filler ||= "\t" * 100)
          end_group(kind)
        end

        private

        def open_token(kind)
          color = @color_scopes.last[kind]
          if color
            if color.is_a?(Hash)
              @color_scopes << color
            else
              @color_scopes << @color_scopes.last
            end
          else
            @color_scopes << @color_scopes.last
          end
        end
      end
    end
  end
end
