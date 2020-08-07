# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to exit program execution.
    class ExitCommand < Pry::ClassCommand
      group 'RubyJard'
      description 'Exit program execution.'

      match 'exit'

      banner <<-BANNER
      Usage: exit
      Examples:
        exit

      Exit program execution. The program will stop at the next breakpoint, or run until it finishes.
      BANNER

      def process
        RubyJard::ControlFlow.dispatch(:exit)
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::ExitCommand)
