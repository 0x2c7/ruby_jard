# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to continue program execution to the next line.
    class NextCommand < Pry::ClassCommand
      include RubyJard::Commands::ValidationHelpers

      group 'RubyJard'
      description 'Next into the execution of the current line'

      match 'next'

      banner <<-BANNER
      Usage: next [times]
      Examples:
        next
        next 1
        next 7

      Continue program execution to the next line. If the current frame reaches the end, it continue the next line of upper frame.
      BANNER

      def process
        times = validate_positive_integer!(args.first || 1)

        RubyJard::ControlFlow.dispatch(:next, times: times.to_i)
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::NextCommand)
Pry::Commands.alias_command 'n', 'next'
