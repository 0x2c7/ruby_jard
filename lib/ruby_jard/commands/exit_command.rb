# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to exit program execution.
    class ExitCommand < BaseCommand
      group 'RubyJard'
      description 'Exit program execution.'
      match 'exit'
      help_doc './exit_command.doc.txt'

      def process
        RubyJard::ControlFlow.dispatch(:exit)
      end
    end
  end
end

RubyJard::PryProxy::Commands.add_command(RubyJard::Commands::ExitCommand)
