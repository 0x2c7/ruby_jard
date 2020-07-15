# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to continue program execution to the next line.
    class NextCommand < Pry::ClassCommand
      group 'RubyJard'
      description 'Next into the execution of the current line'

      match 'next'

      banner <<-BANNER
      Usage: next

      Continue program execution to the next line. If the current frame reaches the end, it continue the next line of upper frame.

      Examples:
        next
      BANNER

      def process
        RubyJard::ControlFlow.dispatch(:next)
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::NextCommand)
