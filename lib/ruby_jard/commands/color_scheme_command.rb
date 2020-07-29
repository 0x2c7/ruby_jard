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

      def options(opt)
        opt.on :l, :list, "List all available color schemes"
      end

      def process
        if opts[:l]
          if args.length != 0
            raise Pry::CommandError, "Color scheme list command shouldn't have any argument."
          end
          pry_instance.pager.page RubyJard::ColorSchemes.names.join("\n")
        else
          color_scheme = args.first.to_s.strip
          if color_scheme.empty?
            raise Pry::CommandError, "You must provide a color scheme name."
          end
          if RubyJard::ColorSchemes[color_scheme].nil?
            raise Pry::CommandError, "Color scheme `#{color_scheme}` not found. Please use `color-scheme -l` to list all color schemes."
          end
          RubyJard::ControlFlow.dispatch(:color_scheme, color_scheme: color_scheme)
        end
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::ColorSchemeCommand)
