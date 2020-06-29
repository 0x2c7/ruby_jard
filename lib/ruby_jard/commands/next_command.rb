# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to continue program execution to the next line.
    # Data attached in the throw:
    # * command: constant symbol (:next)
    # * pry: current context pry instance
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
        throw :control_flow, command: :next, pry: pry_instance
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::NextCommand)
