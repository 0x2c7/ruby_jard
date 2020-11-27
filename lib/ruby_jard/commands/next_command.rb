# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to continue program execution to the next line.
    class NextCommand < BaseCommand
      include RubyJard::Commands::ValidationHelpers

      group 'RubyJard'
      description 'Next into the execution of the current line'
      match 'next'
      help_doc './next_command.doc.txt'

      def process
        times = validate_positive_integer!(args.first || 1)

        RubyJard::ControlFlow.dispatch(:next, times: times.to_i)
      end
    end
  end
end

RubyJard::PryProxy::Commands.add_command(RubyJard::Commands::NextCommand)
RubyJard::PryProxy::Commands.alias_command 'n', 'next'
