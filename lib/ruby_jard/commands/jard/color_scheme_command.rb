# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to explore stacktrace.
    class ColorSchemeCommand < Pry::ClassCommand
      include RubyJard::Commands::ColorHelpers

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
            print_color_schemes
          end
        else
          color_scheme = args.first.to_s.strip
          if color_scheme.empty?
            raise Pry::CommandError,
                  'You must provide a color scheme name. '\
                  "Please use `#{highlight('jard color-scheme -l')}` to list all color schemes."
          end

          if @color_schemes[color_scheme].nil?
            raise Pry::CommandError,
                  "Color scheme `#{secondary(color_scheme)}` not found. "\
                  "Please use `#{highlight('jard color-scheme -l')}` to list all color schemes."
          end

          @config.color_scheme = color_scheme
          RubyJard::ControlFlow.dispatch(:list)
        end
      end

      private

      def print_color_schemes
        pry_instance.output.puts
        pry_instance.output.puts highlight("#{@color_schemes.names.length} available color schemes")
        pry_instance.output.puts
        padding = @color_schemes.names.map(&:length).max
        @color_schemes.names.each do |name|
          scheme = @color_schemes[name]
          decorator = RubyJard::Decorators::ColorDecorator.new(scheme.new)
          pallete = scheme.const_get(:STYLES).keys.map do |style|
            decorator.decorate(style, '⬤ ')
          end.join(' ')
          pry_instance.output.puts "#{name.ljust(padding)} #{pallete}"
          pry_instance.output.puts
        end
      end
    end
  end
end
