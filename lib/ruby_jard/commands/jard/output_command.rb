# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to explore stacktrace.
    class OutputCommand < Pry::ClassCommand
      group 'RubyJard'
      description 'Show all current program output'

      match 'output'

      banner <<-BANNER
        Usage: output
      BANNER

      def initialize(*args)
        super(*args)
        @session = (context[:session] || RubyJard::Session)
      end

      def process
        pry_instance.pager.open(
          force_open: true,
          pager_start_at_the_end: true,
          prompt: 'Program output'
        ) do |pager|
          @session.output_buffer.each do |string|
            string.each do |s|
              pager.write(s)
            end
          end
        end
      end
    end
  end
end
