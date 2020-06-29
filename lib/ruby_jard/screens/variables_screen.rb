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
        Class => :cls # Sorry, I lied, Class will never change
      }.freeze
      TYPE_SYMBOL_PADDING = TYPE_SYMBOLS.map { |_, s| s.to_s.length }.max + 1
      DEFAULT_TYPE_SYMBOL = :var

      INSPECTION_ELLIPSIS = ' [...]'

      KINDS = [
        KIND_LOC = :loc,
        KIND_INS = :ins,
        KIND_CON = :con
      ].freeze

      KIND_PRIORITIES = {
        KIND_LOC => 1,
        KIND_INS => 2,
        KIND_CON => 3
      }.freeze

      KIND_COLORS = {
        KIND_LOC => :yellow,
        KIND_INS => :blue,
        KIND_CON => :green
      }.freeze

      def draw
        @output.print TTY::Box.frame(
          **default_frame_styles.merge(
            top: @row, left: @col, width: @layout.width, height: @layout.height
          )
        )

        @output.print TTY::Cursor.move_to(@col + 1, @row)
        @output.print decorate_text
          .with_highlight(true)
          .text('Variables ', :bright_yellow)
          .content

        decorated_variables.first(data_size).each_with_index do |variable, index|
          @output.print TTY::Cursor.move_to(@col + 1, @row + index + 1)
          @output.print variable.content
        end
      end

      private

      def data_size
        @layout.height - 1
      end

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

      def decorated_variables
        return [] if current_frame.nil?

        variables = fetch_local_variables + fetch_instance_variables + fetch_constants

        sort_variables(variables).map do |kind, name, value|
          decorated_variable(kind, name, value)
        end.flatten
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

      def decorated_variable(kind, name, value)
        text =
          decorate_text
          .text(decorated_type(value))
          .with_highlight(true)
          .text(name.to_s, kind_color(kind))
          .text(addition_data(value), :white)
          .text(' = ')
          .with_highlight(false)
        inspect_texts = inspect_value(text, value)
        text.text(inspect_texts.first, :bright_white)

        # TODO: Fix this ugly code
        [text] +
          inspect_texts[1..-1].map do |line|
            decorate_text
          .with_highlight(false)
          .text(' ' * TYPE_SYMBOL_PADDING)
          .text(line, :bright_white)
          end
      end

      def addition_data(value)
        if value.is_a?(Array) && !value.empty?
          " (size: #{value.length})"
        elsif value.is_a?(String) && value.length > 20
          " (size: #{value.length})"
        else
          ''
        end
      end

      def inspect_value(text, value)
        # Split the lines, add padding to align with kind
        length = @layout.width - TYPE_SYMBOL_PADDING - 1
        value_inspect = value.inspect.to_s

        start_pos = 0
        end_pos = @layout.width - 2 - text.length

        texts = []
        3.times do |_index|
          texts << value_inspect[start_pos..end_pos]
          break if end_pos >= value_inspect.length

          start_pos = end_pos + 1
          end_pos += length
        end

        if end_pos < value_inspect.length
          texts.last[texts.last.length - INSPECTION_ELLIPSIS.length - 1..texts.last.length - 1] = INSPECTION_ELLIPSIS
        end

        texts
      end

      def decorated_type(value)
        type_name = TYPE_SYMBOLS[value.class] || DEFAULT_TYPE_SYMBOL
        decorate_text
          .with_highlight(false)
          .text(type_name.to_s.ljust(TYPE_SYMBOL_PADDING), :white)
      end

      def kind_color(kind)
        KIND_COLORS[kind] || :white
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
    end
  end
end

RubyJard::Screens.add_screen(:variables, RubyJard::Screens::VariablesScreen)
