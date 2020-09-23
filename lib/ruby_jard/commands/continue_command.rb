# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to continue program execution.
    class ContinueCommand < Pry::ClassCommand
      group 'RubyJard'
      description 'Continue program execution.'

      match 'continue'

      banner <<-BANNER
      Usage: continue
      Examples:
        continue

      Continue the execution of your program to the end, or stop at the first dynamic break point or `jard` attachment command.
      BANNER

      def process
        RubyJard::ControlFlow.dispatch(:continue)
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::ContinueCommand)
Pry::Commands.alias_command 'c', 'continue'
