# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to explore stacktrace.
    class ShowOutputCommand < Pry::ClassCommand
      group 'RubyJard'
      description 'Show all current program output'

      match 'show-output'

      banner <<-BANNER
        Usage: show-output
      BANNER

      def self.output_storage
        RubyJard::ScreenManager.instance.output_storage
      end

      def process
        pry_instance.pager.open(force_open: true, pager_start_at_the_end: true) do |pager|
          self.class.output_storage.rewind
          pager.write self.class.output_storage.read until self.class.output_storage.eof?
        end
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::ShowOutputCommand)
