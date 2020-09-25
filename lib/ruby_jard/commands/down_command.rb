# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to explore stacktrace.
    class DownCommand < BaseCommand
      include RubyJard::Commands::ValidationHelpers

      group 'RubyJard'
      description 'Explore the frames bellow the current stopped line in the backtrace'
      match 'down'
      help_doc './down_command.doc.txt'

      def process
        times = validate_positive_integer!(args.first || 1)
        RubyJard::ControlFlow.dispatch(:down, times: times.to_i)
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::DownCommand)
