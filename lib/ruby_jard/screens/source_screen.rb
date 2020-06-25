# frozen_string_literal: true

module RubyJard
  module Screens
    class SourceScreen < RubyJard::Screen
      def draw
        @output.print TTY::Box.frame(
          **default_frame_styles.merge(
            top: @row, left: @col, width: @layout.width, height: @layout.height,
          )
        )

        @output.print TTY::Cursor.move_to(@col + 2, @row)
        @output.print decorate_text
          .with_highlight(true)
          .text(' Source', :bright_yellow)
          .text(' (', :bright_yellow)
          .text(file_path, :bright_yellow)
          .text(') ', :bright_yellow)
          .content

        decorate_codes.each_with_index do |decorated_loc, index|
          @output.print TTY::Cursor.move_to(@col + 1, @row + 1 + index)
          @output.print decorated_loc.content
        end
      end

      private

      def data_size
        @layout.height - 1
      end

      def decorate_codes
        return [] if RubyJard.current_session.frame.nil?

        decorated_source = decorate_source(current_file, current_line, data_size)

        lineno_padding = decorated_source.window_end.to_s.length

        decorated_source.codes.map.with_index do |loc, index|
          lineno = decorated_source.window_start + index
          decorated_loc = decorate_loc(loc, current_line == lineno)

          if current_line == lineno
            decorate_text
              .with_highlight(true)
              .text('→ ')
              .text(lineno.to_s.ljust(lineno_padding), :bright_yellow)
              .text(' ')
              .text(decorated_loc.loc)
              .text(inline_variables(decorated_loc.tokens))
          else
            decorate_text
              .with_highlight(false)
              .text('  ')
              .text(lineno.to_s.ljust(lineno_padding), :white)
              .text(' ')
              .text(decorated_loc.loc)
          end
        end
      end

      def file_path
        return '' if RubyJard.current_session.frame.nil?

        decorated_path = decorate_path(current_file, current_line)
        if decorated_path.gem?
          "#{decorated_path.gem}: #{decorated_path.path}:#{decorated_path.lineno}"
        else
          "#{decorated_path.path}:#{decorated_path.lineno}"
        end
      end

      def current_binding
        RubyJard.current_session.frame._binding
      end

      def current_frame_scope
        RubyJard.current_session.backtrace[RubyJard.current_session.frame.pos][1]
      end

      def current_file
        RubyJard.current_session.frame.file
      end

      def current_line
        RubyJard.current_session.frame.line
      end

      def inline_variables(tokens)
        variables = {}
        local_variables = current_binding.local_variables
        instance_variables = current_frame_scope.instance_variables

        tokens.each_slice(2).each do |token, kind|
          token = token.to_sym

          if kind == :ident && local_variables.include?(token)
            var = current_binding.local_variable_get(token)
          elsif kind == :instance_variable && instance_variables.include?(token)
            var = current_frame_scope.instance_variable_get(token)
          else
            next
          end

          next if variables.key?(token)

          var_inspect = var.inspect
          # TODO: dynamic fill the rest of the line instead
          variables[token] = var_inspect if var_inspect.length < 30
        end

        return '' if variables.empty?

        variables_text = decorate_text.with_highlight(false).text('   #→ ', :white)
        variables.to_a.each_with_index do |(var_name, var_inspect), index|
          variables_text
            .with_highlight(false)
            .text(var_name.to_s, :white)
            .text('=', :white)
            .text(var_inspect, :white)

          if index != variables.length - 1
            variables_text.with_highlight(false).text(', ', :white)
          end
        end

        variables_text
      end
    end
  end
end

RubyJard::Screens.add_screen(:source, RubyJard::Screens::SourceScreen)
