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

      Continue program execution. The program will stop at the next breakpoint, or run until it finishes.

      Examples:
        continue
      BANNER

      def process
        RubyJard::ControlFlow.dispatch(:continue)
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::ContinueCommand)
Pry::Commands.alias_command 'c', 'continue'
