# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to continue program execution.
    # Data attached in the throw:
    # * command: constant symbol (:continue)
    # * pry: current context pry instance
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
        throw :control_flow, command: :continue, pry: pry_instance
      ensure
        Byebug.stop if Byebug.stoppable?
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::ContinueCommand)
