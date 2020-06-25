module RubyJard
  module Decorators
    class LocDecorator
      attr_reader :loc, :tokens

      def initialize(color_decorator, loc, highlighted)
        @loc = loc
        @highlighted = highlighted
        @encoder = JardLocEncoder.new(
          color_decorator: color_decorator,
          highlighted: highlighted
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
          attribute_name: [:yellow],
          attribute_value: [:yellow],
          binary: {
            self: [:yellow],
            char: [:yellow],
            delimiter: [:yellow]
          },
          char: {
            self: [:yellow],
            delimiter: [:yellow]
          },
          class: [:green],
          class_variable: [:blue],
          color: [:green],
          comment: {
            self: [:white],
            char: [:white],
            delimiter: [:white]
          },
          constant: [:green],
          decorator: [:yellow],
          definition: [:yellow],
          directive: [:yellow],
          docstring: [:yellow],
          doctype: [:blue],
          done: [:blue],
          entity: [:yellow],
          error: [:white, :on_red],
          exception: [:yellow],
          float: [:yellow],
          function: [:green],
          method: [:yellow],
          global_variable: [:green],
          hex: [:blue],
          id: [:blue],
          include: [:yellow],
          integer: [:yellow],
          imaginary: [:blue],
          important: [:yellow],
          key: {
            self: [:yellow],
            char: [:yellow],
            delimiter: [:yellow]
          },
          label: [:yellow],
          local_variable: [:yellow],
          namespace: [:yellow],
          octal: [:blue],
          predefined: [:blue],
          predefined_constant: [:blue],
          predefined_type: [:green],
          preprocessor: [:blue],
          pseudo_class: [:blue],
          regexp: {
            self: [:yellow],
            delimiter: [:yellow],
            modifier: [:yellow],
            char: [:yellow]
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
            self: [:yellow],
            modifier: [:yellow],
            char: [:yellow],
            delimiter: [:yellow],
            escape: [:yellow]
          },
          symbol: {
            self: [:yellow],
            delimiter: [:yellow]
          },
          tag: [:green],
          type: [:blue],
          value: [:blue],
          variable: [:blue],
          insert: {
            self: [:on_green],
            insert: [:green, :on_green],
            eyecatcher: [:italic]
          },
          delete: {
            self: [:on_red],
            delete: [:yellow, :on_red],
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
          @highlighted = options[:highlighted]
        end

        public

        def text_token(text, kind)
          color = @color_scopes.last[kind]
          text.gsub!("\n", '')
          if color
            color = color[:self] if color.is_a? Hash
            @out << @color_decorator.decorate(text, *compose_color(color))
          else
            @out << @color_decorator.decorate(text, *compose_color([]))
          end
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

        def compose_color(color)
          if @highlighted
            [:clear] + color
          else
            [:dim] + color
          end
        end
      end
    end
  end
end
