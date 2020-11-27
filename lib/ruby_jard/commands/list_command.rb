# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to explore stacktrace.
    class ListCommand < BaseCommand
      group 'RubyJard'
      description 'Refresh the current UI'
      match 'list'
      help_doc './list_command.doc.txt'

      def process
        RubyJard::ControlFlow.dispatch(:list)
      end
    end
  end
end

RubyJard::PryProxy::Commands.add_command(RubyJard::Commands::ListCommand)
RubyJard::PryProxy::Commands.alias_command 'l', 'list'
RubyJard::PryProxy::Commands.alias_command 'whereami', 'list'
