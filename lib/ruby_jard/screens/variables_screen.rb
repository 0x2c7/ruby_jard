# frozen_string_literal: true

module RubyJard
  module Screens
    class VariablesScreen < RubyJard::Screen
      TYPE_SYMBOLS = {
        # Intertal classes for those values may differ between Ruby versions
        # For example: Bignum is renamed to Integer
        # So, it's safer to use discrete value's class as the key for this mapping.
        true.class => :bool,
        false.class => :bool,
        1.class => :int,
        1.1.class => :flt,
        1.to_r.class => :rat, # Rational: (1/1)
        1.to_c.class => :com, # Complex: (1+0i)
        ''.class => :str,
        :sym.class => :sym,
        [].class => :arr,
        {}.class => :hash,
        //.class => :reg,
        (0..0).class => :rng,
        Class => :cls # Sorry, I lied, Class will never change
      }.freeze
      DEFAULT_TYPE_SYMBOL = :var

      KINDS = [
        KIND_LOC = :local_variable,
        KIND_INS = :instance_variable,
        KIND_CON = :constant
      ].freeze

      KIND_PRIORITIES = {
        KIND_LOC => 1,
        KIND_INS => 2,
        KIND_CON => 3
      }.freeze

      INLINE_TOKEN_KIND_MAPS = {
        KIND_LOC => :ident,
        KIND_INS => :instance_variable,
        KIND_CON => :constant
      }.freeze
      INLINE_TOKEN_KINDS = INLINE_TOKEN_KIND_MAPS.values

      def title
        'Variables'
      end

      def build
        variables = fetch_local_variables + fetch_instance_variables + fetch_constants
        variables = sort_variables(variables)
        @rows = variables.map do |variable|
          RubyJard::Row.new(
            line_limit: 3,
            columns: [
              RubyJard::Column.new(
                spans: [
                  span_inline(variable)
                ]
              ),
              RubyJard::Column.new(
                spans: [
                  span_name(variable),
                  span_size(variable),
                  RubyJard::Span.new(margin_right: 1, content: '=', styles: :variable_assignment),
                  span_inspection(variable)
                ]
              )
            ]
          )
        end
        @selected = 0
      end

      def span_inline(variable)
        if inline?(variable[0], variable[1])
          RubyJard::Span.new(
            content: '•',
            styles: :variable_mark_inline
          )
        else
          RubyJard::Span.new(
            content: ' ',
            styles: :variable_mark
          )
        end
      end

      def span_name(variable)
        RubyJard::Span.new(
          margin_right: 1,
          content: variable[1].to_s,
          styles: variable[0].to_sym
        )
      end

      def span_size(variable)
        value = variable[2]
        size_label =
          if value.is_a?(Array) && !value.empty?
            "(len:#{value.length})"
          elsif value.is_a?(String) && value.length > 20
            "(len:#{value.length})"
          elsif value.is_a?(Hash) && !value.empty?
            "(size:#{value.length})"
          end
        RubyJard::Span.new(
          margin_right: 1,
          content: size_label,
          styles: :variable_size
        )
      end

      def span_inspection(variable)
        # Hard limit: screen area
        inspection = variable[2].inspect[0..@layout.height * @layout.width]
        # TODO: This is just a workable. Should write a decorator to inspect objects accurately
        ["\n", "\r", "\r\n"].each do |esc|
          inspection.gsub!(esc, esc.inspect)
        end
        RubyJard::Span.new(
          content: inspection,
          styles: :variable_inspection
        )
      end

      private

      def current_binding
        RubyJard.current_session.frame._binding
      end

      def current_frame
        RubyJard.current_session.frame
      end

      def current_frame_scope
        RubyJard.current_session.backtrace[RubyJard.current_session.frame.pos][1]
      end

      def current_frame_scope_class
        RubyJard.current_session.backtrace[RubyJard.current_session.frame.pos][2]
      end

      def fetch_local_variables
        variables = current_binding.local_variables
        # Exclude Pry's sticky locals
        pry_sticky_locals =
          if variables.include?(:pry_instance)
            current_binding.local_variable_get(:pry_instance).sticky_locals.keys
          else
            []
          end
        variables -= pry_sticky_locals
        variables.map do |variable|
          [KIND_LOC, variable, current_binding.local_variable_get(variable)]
        rescue NameError
          nil
        end.compact
      end

      def fetch_instance_variables
        current_frame_scope.instance_variables.map do |variable|
          [KIND_INS, variable, current_frame_scope.instance_variable_get(variable)]
        rescue NameError
          nil
        end.compact
      end

      def fetch_constants
        # Filter out truly constants (CONSTANT convention) only
        constant_source =
          if current_frame_scope_class&.singleton_class?
            current_frame_scope
          else
            current_frame_scope_class
          end

        return [] unless constant_source.respond_to?(:constants)

        constants = constant_source.constants.select { |v| v.to_s.upcase == v.to_s }
        constants.map do |variable|
          [KIND_CON, variable, constant_source.const_get(variable)]
        rescue NameError
          nil
        end.compact
      end

      def sort_variables(variables)
        # Sort by kind
        # Sort by "internal" character so that internal variable is pushed down
        # Sort by name
        variables.sort do |a, b|
          if KIND_PRIORITIES[a[0]] != KIND_PRIORITIES[b[0]]
            KIND_PRIORITIES[a[0]] <=> KIND_PRIORITIES[b[0]]
          else
            a_name = a[1].to_s.gsub(/^@/, '')
            b_name = b[1].to_s.gsub(/^@/, '')
            if a_name[0] == '_' && b_name[0] == '_'
              a_name.to_s <=> b_name.to_s
            elsif a_name[0] == '_'
              1
            elsif b_name[0] == '_'
              -1
            else
              a_name.to_s <=> b_name.to_s
            end
          end
        end
      end

      def inline?(kind, name)
        tokens = inline_tokens[INLINE_TOKEN_KIND_MAPS[kind]] || []
        tokens.include?(name)
      end

      def inline_tokens
        return @inline_tokens if defined?(@inline_tokens)

        current_file = RubyJard.current_session.frame.file
        current_line = RubyJard.current_session.frame.line
        source_decorator = RubyJard::Decorators::SourceDecorator.new(current_file, current_line, 1)
        _spans, tokens = loc_decorator.decorate(
          source_decorator.codes[current_line - source_decorator.window_start],
          current_file
        )

        @inline_tokens = {}
        tokens.each_slice(2) do |token, kind|
          next unless INLINE_TOKEN_KINDS.include?(kind)

          @inline_tokens[kind] ||= []
          @inline_tokens[kind] << token.to_s.to_sym
        end

        @inline_tokens
      end
      def loc_decorator
        @loc_decorator ||= RubyJard::Decorators::LocDecorator.new
      end
    end
  end
end

RubyJard::Screens.add_screen(:variables, RubyJard::Screens::VariablesScreen)
