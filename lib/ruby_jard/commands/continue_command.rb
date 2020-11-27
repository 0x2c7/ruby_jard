# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to continue program execution.
    class ContinueCommand < BaseCommand
      group 'RubyJard'
      description 'Continue program execution.'
      match 'continue'
      help_doc './continue_command.doc.txt'

      def process
        RubyJard::ControlFlow.dispatch(:continue)
      end
    end
  end
end

RubyJard::PryProxy::Commands.add_command(RubyJard::Commands::ContinueCommand)
RubyJard::PryProxy::Commands.alias_command 'c', 'continue'
