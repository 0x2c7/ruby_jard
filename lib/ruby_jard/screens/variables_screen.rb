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
      DEFAULT_TYPE_SYMBOL = :var

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

      def title
        'Variables'
      end

      def data_size
        @height
      end

      def data_window
        return [] if current_frame.nil?
        return @data_window if defined?(@data_window)

        variables = fetch_local_variables + fetch_instance_variables + fetch_constants
        @data_window = sort_variables(variables).first(data_size)
      end

      def draw
        adjust_screen_size_to_borders

        calculate
        # TODO: move this out to ScreenManager
        drawer = RubyJard::ScreenDrawer.new(
          output: @output,
          screen: self,
          x: @col,
          y: @row
        )
        drawer.draw
      end

      def span_type(data_row, _index)
        type_name = TYPE_SYMBOLS[data_row[2].class] || DEFAULT_TYPE_SYMBOL
        [type_name.to_s, :white]
      end

      def span_name(data_row, _index)
        [
          data_row[1].to_s,
          [
            KIND_COLORS[data_row[0]] || :white,
            :bold
          ]
        ]
      end

      def span_indicator(_data_row, _index)
        ['=', [:bright_white]]
      end

      def span_size(data_row, _index)
        value = data_row[2]
        if value.is_a?(Array) && !value.empty?
          ["(size: #{value.length})", :white]
        elsif value.is_a?(String) && value.length > 20
          ["(size: #{value.length})", :white]
        end
      end

      def span_inspection(data_row, _index)
        # Hard limit: screen area
        [data_row[2].inspect[0..@height * @width], :white]
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
    end
  end
end

RubyJard::Screens.add_screen(:variables, RubyJard::Screens::VariablesScreen)
