# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to finish up the current frame.
    # Data attached in the throw:
    # * command: constant symbol (:finish)
    # * pry: current context pry instance
    class FinishCommand < Pry::ClassCommand
      group 'RubyJard'
      description 'Finish the execution of the current frame.'

      match 'finish'

      banner <<-BANNER
      Usage: finish

      Finish the execution of the current frame.

      Examples:
        finish
      BANNER

      def process
        throw :control_flow, command: :finish, pry: pry_instance
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::FinishCommand)
