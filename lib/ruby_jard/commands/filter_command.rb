# frozen_string_literal: true

module RubyJard
  module Commands
    ##
    # Control filter, included and excluded
    class FilterCommand < Pry::ClassCommand
      include RubyJard::Commands::ColorHelpers

      group 'RubyJard'
      description 'Filter to keep only relevant location when you debugging'

      match 'filter'

      banner <<-BANNER
        Usage:
          jard filter
          jard filter [everything, gems, application, source_tree]
          jard filter [include, exclude] pattern
          jard filter clear

        Ruby Jard has a strong filtering system. This system consists of a filter mode, included list, and excluded list. Filter mode is how Ruby Jard reacts to control flow commands. See https://rubyjard.org/docs/guides/filter for more information.

        Examples:

          jard filter # Show filter status

          jard filter application # Switch to application mode
          jard filter gems # Switch to gems mode
          jard filter everything # Switch to everything mode
          jard filter source_tree # Switch to source tree mode

          jard filter include sidekiq # Include sidekiq pattern
          jard filter include aws-*
          jard filter include aws-* active* action* # Multiple patterns separated by <space>
          jard filter include lib/**/*.erb
          jard filter include ~/home/lib/**/*.rb

          jard filter exclude sidekiq # exclude sidekiq pattern
          jard filter exclude aws-*
          jard filter exclude aws-* active* action* # Multiple patterns separated by <space>
          jard filter exclude lib/**/*.erb
          jard filter exclude ~/home/lib/**/*.rb

          jard filter clear # Clear filter
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
          handle_included
        when :exclude
          handle_excluded
        when :clear
          handle_clear
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
        @config.filter_included.append(*filters)
        @config.filter_included.uniq!
        filters.each do |filter|
          @config.filter_excluded.delete(filter) if @config.filter_excluded.include?(filter)
        end
        RubyJard::ControlFlow.dispatch(:list)
      end

      def handle_excluded
        if args.empty?
          raise Pry::CommandError,
                'Wrong number of arguments!'\
                "Please type `#{highlight('jard filter --help')}` for more information"
        end
        filters = args.map(&:strip)
        @config.filter_excluded.append(*filters)
        @config.filter_excluded.uniq!
        filters.each do |filter|
          @config.filter_included.delete(filter) if @config.filter_included.include?(filter)
        end
        RubyJard::ControlFlow.dispatch(:list)
      end

      def handle_clear
        @config.filter_excluded.clear
        @config.filter_included.clear
        RubyJard::ControlFlow.dispatch(:list)
      end
    end
  end
end
