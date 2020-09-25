# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to explore stacktrace.
    class UpCommand < BaseCommand
      include RubyJard::Commands::ValidationHelpers

      group 'RubyJard'
      description 'Explore the frames above the current stopped line in the backtrace'
      match 'up'
      help_doc './up_command.doc.txt'

      def process
        times = validate_positive_integer!(args.first || 1)

        RubyJard::ControlFlow.dispatch(:up, times: times.to_i)
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::UpCommand)
