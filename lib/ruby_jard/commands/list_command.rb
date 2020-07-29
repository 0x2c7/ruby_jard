# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to explore stacktrace.
    class ListCommand < Pry::ClassCommand
      group 'RubyJard'
      description 'Refresh the current UI'

      match 'list'

      banner <<-BANNER
      Usage:
        - list
        - l

      Refresh the current UI.

      BANNER

      def process
        RubyJard::ControlFlow.dispatch(:list)
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::ListCommand)
Pry::Commands.alias_command 'l', 'list'
Pry::Commands.alias_command 'whereami', 'list'
