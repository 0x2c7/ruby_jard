# frozen_string_literal: true

module RubyJard
  module Commands
    ##
    # Control filter, inclusion and exclusion
    class FilterCommand < Pry::ClassCommand
      group 'RubyJard'
      description 'Filter to keep only relevant location when you debugging'

      match 'output'

      banner <<-BANNER
        Usage: output
      BANNER

      def initialize(*args)
        super(*args)
        @filters = RubyJard::PathFilter::FILTERS
        @config = context[:config] || RubyJard.config
      end

      def options(opt)
        opt.on :l, :list, 'List all available color schemes'
      end

      def process
        if opts[:l] || (opts.empty? && args.empty?)
          pry_instance.output.puts filter_list_msg
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
                "Invalid filter `#{sub_command}`. #{filter_list_msg}. Or type `jard filter --help` for more information"
        end
      end

      def filter_list_msg
        filter_output = @filters.map(&:to_s).join(', ')
        "Please input one of the following filter: #{filter_output}"
      end

      private

      def handle_inclusion
        if args.empty?
          raise Pry::CommandError,
                'Invalid command. Please type `jard filter --help` for more information'
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
                'Invalid command. Please type `jard filter --help` for more information'
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
