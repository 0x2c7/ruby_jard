# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to explore stacktrace.
    class ColorSchemeCommand < Pry::ClassCommand
      group 'RubyJard'
      description 'Control the color scheme used in Jard'

      match 'color-scheme'

      banner <<-BANNER
        Usage: color-scheme -l
               color-scheme [scheme-name]
      BANNER

      def initialize(context = {})
        super(context)
        @color_schemes = context[:color_schemes] || RubyJard::ColorSchemes
        @config = context[:config] || RubyJard.config
      end

      def options(opt)
        opt.on :l, :list, 'List all available color schemes'
      end

      def process
        if opts[:l]
          if @color_schemes.names.empty?
            pry_instance.output.puts 'No loaded color schemes'
          else
            pry_instance.output.puts @color_schemes.names.join("\n")
          end
        else
          color_scheme = args.first.to_s.strip
          if color_scheme.empty?
            raise Pry::CommandError,
                  'You must provide a color scheme name. Please use `color-scheme -l` to list all color schemes.'
          end

          if @color_schemes[color_scheme].nil?
            raise Pry::CommandError,
                  "Color scheme `#{color_scheme}` not found. Please use `color-scheme -l` to list all color schemes."
          end

          @config.color_scheme = color_scheme
          RubyJard::ControlFlow.dispatch(:list)
        end
      end
    end
  end
end
