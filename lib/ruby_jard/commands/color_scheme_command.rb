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

      def self.color_scheme_names
        RubyJard::ColorSchemes.names
      end

      def self.get_color_scheme(color_scheme)
        RubyJard::ColorSchemes[color_scheme]
      end

      def options(opt)
        opt.on :l, :list, 'List all available color schemes'
      end

      def process
        if opts[:l]
          color_scheme_names = self.class.color_scheme_names
          if color_scheme_names.empty?
            pry_instance.output.puts 'No loaded color schemes'
          else
            pry_instance.output.puts self.class.color_scheme_names.join("\n")
          end
        else
          color_scheme = args.first.to_s.strip
          if color_scheme.empty?
            raise Pry::CommandError,
                  'You must provide a color scheme name. Please use `color-scheme -l` to list all color schemes.'
          end

          if self.class.get_color_scheme(color_scheme).nil?
            raise Pry::CommandError,
                  "Color scheme `#{color_scheme}` not found. Please use `color-scheme -l` to list all color schemes."
          end

          RubyJard::ControlFlow.dispatch(:color_scheme, color_scheme: color_scheme)
        end
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::ColorSchemeCommand)
