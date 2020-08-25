# frozen_string_literal: true

module RubyJard
  module Commands
    ##
    # Control filter, inclusion and exclusion
    class FilterCommand < Pry::ClassCommand
      include RubyJard::Commands::ColorHelpers

      group 'RubyJard'
      description 'Filter to keep only relevant location when you debugging'

      match 'filter'

      banner <<-BANNER
        Usage: output
      BANNER

      def initialize(*args)
        super(*args)
        @filters = RubyJard::PathFilter::FILTERS
        @config = context[:config] || RubyJard.config
      end

      def process
        if args.empty?
          print_current_filter
          return
        end

        sub_command = args.shift.to_sym

        case sub_command
        when *@filters
          @config.filter = sub_command
          RubyJard::ControlFlow.dispatch(:list)
        when :include
          handle_inclusion
        when :exclude
          handle_exclusion
        when :clear
          handle_clear
        else
          raise Pry::CommandError,
                "Invalid filter '#{secondary(sub_command)}'."\
                "Please type `#{highlight('jard filter --help')}` for more information"
        end
      end

      private

      def print_current_filter
        pry_instance.output.puts
        pry_instance.output.puts highlight('Filter mode')
        pry_instance.output.puts "  #{@config.filter}"
        pry_instance.output.puts highlight("Included (#{@config.filter_inclusion.length})")
        @config.filter_inclusion.each do |inclusion|
          pry_instance.output.puts "  +#{inclusion}"
        end

        pry_instance.output.puts highlight("Excluded (#{@config.filter_exclusion.length})")
        @config.filter_exclusion.each do |exclusion|
          pry_instance.output.puts "  -#{exclusion}"
        end
        pry_instance.output.puts
        pry_instance.output.puts "Please type `#{highlight('jard filter --help')}` for more information"
        pry_instance.output.puts
      end

      def handle_inclusion
        if args.empty?
          raise Pry::CommandError,
                'Wrong number of arguments! '\
                "Please type `#{highlight('jard filter --help')}` for more information"
        end
        filters = args.map(&:strip)
        @config.filter_inclusion.append(*filters)
        @config.filter_inclusion.uniq!
        filters.each do |filter|
          @config.filter_exclusion.delete(filter) if @config.filter_exclusion.include?(filter)
        end
        RubyJard::ControlFlow.dispatch(:list)
      end

      def handle_exclusion
        if args.empty?
          raise Pry::CommandError,
                'Wrong number of arguments!'\
                "Please type `#{highlight('jard filter --help')}` for more information"
        end
        filters = args.map(&:strip)
        @config.filter_exclusion.append(*filters)
        @config.filter_exclusion.uniq!
        filters.each do |filter|
          @config.filter_inclusion.delete(filter) if @config.filter_inclusion.include?(filter)
        end
        RubyJard::ControlFlow.dispatch(:list)
      end

      def handle_clear
        @config.filter_exclusion.clear
        @config.filter_inclusion.clear
        RubyJard::ControlFlow.dispatch(:list)
      end
    end
  end
end
