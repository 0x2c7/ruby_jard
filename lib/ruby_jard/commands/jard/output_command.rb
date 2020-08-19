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
        pry_instance.pager.open(force_open: true, pager_start_at_the_end: true) do |pager|
          self.class.output_storage.rewind
          pager.write self.class.output_storage.read_nonblock(2048) until self.class.output_storage.eof?
        end
      end
    end
  end
end
