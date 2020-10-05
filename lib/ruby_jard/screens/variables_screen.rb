# frozen_string_literal: true

module RubyJard
  class Screens
    ##
    # Display the relevant variables and constants of current context, scopes
    class VariablesScreen < RubyJard::Screen
      include ::RubyJard::Span::DSL

      KINDS = [
        KIND_SELF = :self,
        KIND_LOC  = :local_variable,
        KIND_INS  = :instance_variable,
        KIND_CON  = :constant,
        KIND_GLOB = :global_variable
      ].freeze

      KIND_STYLES = {
        KIND_SELF => :constant,
        KIND_LOC  => :local_variable,
        KIND_INS  => :instance_variable,
        KIND_CON  => :constant,
        KIND_GLOB => :instance_variable
      }.freeze

      KIND_PRIORITIES = {
        KIND_SELF => 0,
        KIND_LOC  => 1,
        KIND_INS  => 2,
        KIND_CON  => 3,
        KIND_GLOB => 4
      }.freeze

      TOKEN_KIND_MAPS = {
        ident: KIND_LOC,
        instance_variable: KIND_INS,
        constant: KIND_CON,
        predefined_constant: KIND_CON,
        global_variable: KIND_GLOB
      }.freeze
      TOKEN_KINDS = TOKEN_KIND_MAPS.keys.flatten

      def initialize(*args)
        super

        @frame_file = @session.current_frame&.frame_file
        @frame_line = @session.current_frame&.frame_line
        @frame_self = @session.current_frame&.frame_self
        @frame_class = @session.current_frame&.frame_class
        @frame_binding = @session.current_frame&.frame_binding

        @inline_tokens = generate_inline_tokens(@frame_file, @frame_line)
        @file_tokens = generate_file_tokens(@frame_file)

        @inspector = RubyJard::Inspectors::Base.new

        @selected = 0
      end

      def title
        'Variables'
      end

      def build
        variables = fetch_relevant_variables
        @rows = variables.map do |variable|
          name = span_name(variable)
          size = span_size(variable)
          assignment = text_primary(' = ')
          inline_limit =
            (@layout.width - 3) * 3 - name.content_length - size.content_length - assignment.content_length
          inspections = @inspector.multiline(
            variable[2], first_line_limit: inline_limit, line_limit: @layout.width - 3, lines: 7
          )
          base_inspection = inspections.shift
          mark = span_mark(variable, inspections)
          [
            base_row(name, size, assignment, mark, base_inspection),
            nested_rows(variable, inspections)
          ]
        end.flatten.compact
      end

      def fetch_relevant_variables
        sort_variables(
          self_variable +
          fetch_local_variables +
          fetch_instance_variables +
          fetch_constants +
          fetch_global_variables
        )
      end

      def base_row(name, size, assignment, mark, base_inspection)
        RubyJard::Row.new(
          line_limit: 3,
          columns: [
            RubyJard::Column.new(spans: [mark]),
            RubyJard::Column.new(
              word_wrap: RubyJard::Column::WORD_WRAP_BREAK_WORD,
              spans: [name, size, assignment, base_inspection.spans].flatten.compact
            )
          ]
        )
      end

      def nested_rows(variable, nested_inspections)
        return nil if nested_inspections.empty? || variable[0] == KIND_SELF

        nested_inspections.map do |row|
          RubyJard::Row.new(
            line_limit: 1,
            columns: [
              RubyJard::Column.new,
              RubyJard::Column.new(
                word_wrap: RubyJard::Column::WORD_WRAP_BREAK_WORD,
                spans: row.spans
              )
            ]
          )
        end
      end

      def span_mark(variable, nested_inspections)
        if variable[0] == KIND_SELF || nested_inspections.empty?
          text_dim(' ')
        else
          text_dim('▾')
        end
      end

      def span_name(variable)
        RubyJard::Span.new(
          content: variable[1].to_s,
          styles: [KIND_STYLES[variable[0].to_sym], inline?(variable[1]) ? :underline : nil]
        )
      end

      def span_size(variable)
        value = variable[2]
        if RubyJard::Reflection.call_is_a?(value, Array) && !value.empty?
          text_primary(" (len:#{value.length})")
        elsif RubyJard::Reflection.call_is_a?(value, String) && value.length > 20
          text_primary(" (len:#{value.length})")
        elsif RubyJard::Reflection.call_is_a?(value, Hash) && !value.empty?
          text_primary(" (size:#{value.length})")
        else
          text_primary('')
        end
      end

      private

      def fetch_local_variables
        return [] if @frame_binding == nil
        return [] unless RubyJard::Reflection.call_is_a?(@frame_binding, ::Binding)

        variables = @frame_binding.local_variables
        # Exclude Pry's sticky locals
        pry_sticky_locals =
          if variables.include?(:pry_instance)
            @frame_binding.local_variable_get(:pry_instance)&.sticky_locals&.keys || []
          else
            []
          end
        variables -= pry_sticky_locals
        variables.map do |variable|
          [KIND_LOC, variable, @frame_binding.local_variable_get(variable)]
        rescue NameError
          nil
        end.compact
      end

      def fetch_instance_variables
        return [] if @frame_self == nil

        instance_variables =
          RubyJard::Reflection
          .call_instance_variables(@frame_self)
          .select { |v| relevant?(KIND_INS, v) }

        instance_variables.map do |variable|
          [KIND_INS, variable, RubyJard::Reflection.call_instance_variable_get(@frame_self, variable)]
        rescue NameError
          nil
        end.compact
      end

      def fetch_constants
        return [] if @frame_class == nil

        # Filter out truly constants (CONSTANT convention) only
        constant_source =
          if @frame_class&.singleton_class?
            @frame_self
          else
            @frame_class
          end

        (@file_tokens[KIND_CON] || {})
          .keys
          .select { |c| c.upcase == c }
          .uniq
          .map { |const| fetch_constant(constant_source, const) }
          .compact
      end

      def fetch_constant(constant_source, const)
        return nil if %w[NIL TRUE FALSE].include?(const.to_s)
        return nil unless RubyJard::Reflection.call_const_defined?(constant_source, const)

        [KIND_CON, const, RubyJard::Reflection.call_const_get(constant_source, const)]
      rescue NameError
        nil
      end

      def fetch_global_variables
        return [] if @frame_self == nil

        variables =
          ::Kernel
          .global_variables
          .select { |v| relevant?(KIND_GLOB, v) }
        variables.map do |variable|
          [KIND_GLOB, variable, ::Kernel.instance_eval(variable.to_s)]
        rescue NameError
          nil
        end.compact
      end

      def self_variable
        [[KIND_SELF, :self, @frame_self]]
      rescue StandardError
        []
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

      def inline?(name)
        @inline_tokens[name]
      end

      def relevant?(kind, name)
        @file_tokens[kind] != nil && @file_tokens[kind][name]
      end

      def generate_inline_tokens(file, line)
        return [] if file == nil || line == nil

        loc_decorator = RubyJard::Decorators::LocDecorator.new
        source_decorator = RubyJard::Decorators::SourceDecorator.new(file, line, 1)
        _spans, tokens = loc_decorator.decorate(
          source_decorator.codes[line - source_decorator.window_start],
          file
        )

        inline_tokens = {}
        tokens.each_slice(2) do |token, kind|
          next if TOKEN_KIND_MAPS[kind] == nil

          inline_tokens[token.to_s.to_sym] = true
        end
        inline_tokens
      end

      def generate_file_tokens(file)
        return [] if file == nil

        loc_decorator = RubyJard::Decorators::LocDecorator.new
        # TODO: This is a mess
        source_decorator = RubyJard::Decorators::SourceDecorator.new(file, 1, 10_000)
        _spans, tokens = loc_decorator.decorate(source_decorator.codes.join("\n"), file)

        file_tokens = {}
        tokens.each_slice(2) do |token, kind|
          next if TOKEN_KIND_MAPS[kind] == nil

          file_tokens[TOKEN_KIND_MAPS[kind]] ||= {}
          file_tokens[TOKEN_KIND_MAPS[kind]][token.to_s.to_sym] = true
        end
        file_tokens
      end
    end
  end
end

RubyJard::Screens.add_screen('variables', RubyJard::Screens::VariablesScreen)
