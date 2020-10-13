# frozen_string_literal: true

module RubyJard
  module Commands
    ##
    # Control filter, included and excluded
    class FilterCommand < BaseCommand
      include RubyJard::Commands::ColorHelpers

      group 'RubyJard'
      description 'Filter to keep only relevant location when you debugging'
      match 'filter'
      help_doc './filter_command.doc.txt'

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
          handle_included
        when :exclude
          handle_excluded
        when :clear
          handle_clear
        when :switch
          handle_switch
        else
          raise Pry::CommandError,
                "Invalid filter '#{highlight(sub_command)}'."\
                "Please type `#{highlight('jard filter --help')}` for more information"
        end
      end

      private

      def print_current_filter
        pry_instance.output.puts
        pry_instance.output.puts highlight('Filter mode')
        pry_instance.output.puts "  #{@config.filter}"
        pry_instance.output.puts highlight("Included (#{@config.filter_included.length})")
        @config.filter_included.each do |included|
          pry_instance.output.puts "  +#{included}"
        end

        pry_instance.output.puts highlight("Excluded (#{@config.filter_excluded.length})")
        @config.filter_excluded.each do |excluded|
          pry_instance.output.puts "  -#{excluded}"
        end
        pry_instance.output.puts
        pry_instance.output.puts "Please type `#{highlight('jard filter --help')}` for more information"
        pry_instance.output.puts
      end

      def handle_included
        if args.empty?
          raise Pry::CommandError,
                'Wrong number of arguments! '\
                "Please type `#{highlight('jard filter --help')}` for more information"
        end
        filters = args.map(&:strip)
        included = @config.filter_included.dup.append(*filters).uniq
        excluded = @config.filter_excluded.dup
        filters.each do |filter|
          excluded.delete(filter) if excluded.include?(filter)
        end

        @config.filter_included = included
        @config.filter_excluded = excluded
        RubyJard::ControlFlow.dispatch(:list)
      end

      def handle_excluded
        if args.empty?
          raise Pry::CommandError,
                'Wrong number of arguments!'\
                "Please type `#{highlight('jard filter --help')}` for more information"
        end
        filters = args.map(&:strip)

        included = @config.filter_included.dup
        excluded = @config.filter_excluded.dup.append(*filters).uniq

        filters.each do |filter|
          included.delete(filter) if included.include?(filter)
        end

        @config.filter_included = included
        @config.filter_excluded = excluded
        RubyJard::ControlFlow.dispatch(:list)
      end

      def handle_clear
        @config.filter_excluded = []
        @config.filter_included = []
        RubyJard::ControlFlow.dispatch(:list)
      end

      def handle_switch
        @config.filter = RubyJard::PathFilter.next_filter(@config.filter)
        RubyJard::ControlFlow.dispatch(:list)
      end
    end
  end
end
