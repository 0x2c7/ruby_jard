# frozen_string_literal: true

module RubyJard
  module Screens
    class VariablesScreen < RubyJard::Screen
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
        @layout.height - 2
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

      def decorated_variables
        return [] if current_frame.nil?

        variables = []
        variables_hash = {}

        current_frame.args.map do |arg|
          variable = arg.last
          next if variables_hash[variable] || variable.nil?

          variables << [:arg, variable, current_binding.local_variable_get(variable)]
          variables_hash[variable] = true
        end

        sort_variables(current_binding.local_variables).map do |variable|
          next if variables_hash[variable]

          variables << [:loc, variable, current_binding.local_variable_get(variable)]
          variables_hash[variable] = true
        end

        sort_variables(current_frame_scope.instance_variables).map do |variable|
          next if variables_hash[variable]

          variables << [:ins, variable, current_frame_scope.instance_variable_get(variable)]
          variables_hash[variable] = true
        end

        variables.map do |kind, name, value|
          decorated_variable(kind, name, value)
        end.flatten
      end

      def decorated_variable(kind, name, value)
        text =
          decorate_text
          .text(decoreated_kind(kind))
          .text(' ')
          .with_highlight(true)
          .text(name.to_s, :bright_white)
          .text(addition_data(value), :white)
          .with_highlight(false)
          .text(' = ')
        inspect_texts = inspect_value(text, value)
        text.text(inspect_texts.first, :white)

        # TODO: Fix this ugly code
        [text] +
        inspect_texts[1..-1].map do |line|
          decorate_text
            .text('    ')
            .text(line, :white)
        end
      end

      def addition_data(value)
        if value.is_a?(Array)
          " (size: #{value.length})"
        elsif value.is_a?(String) && value.length > 20
          " (size: #{value.length})"
        else
          ''
        end
      end

      def inspect_value(text, value)
        # Split the lines, add padding to align with kind
        length = @layout.width - 6
        value_inspect = value.inspect.to_s

        start_pos = 0
        end_pos = @layout.width - 2 - text.length

        texts = []
        3.times do |index|
          texts << value_inspect[start_pos..end_pos]
          start_pos = end_pos + 1
          end_pos += length
          break if end_pos >= value_inspect.length
        end

        if end_pos < value_inspect.length
          texts.last[texts.last.length - 6..texts.last.length - 1] = ' [...]'
        end

        texts
      end

      def decoreated_kind(kind)
        kind_color =
          case kind
          when :arg
            :yellow
          when :loc
            :green
          else
            :white
          end

        decorate_text
          .with_highlight(false)
          .text(kind.to_s, kind_color)
      end

      def sort_variables(variables)
        variables.sort do |a, b|
          a.to_s <=> b.to_s
        end
      end
    end
  end
end

RubyJard::Screens.add_screen(:variables, RubyJard::Screens::VariablesScreen)
