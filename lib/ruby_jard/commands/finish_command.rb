# frozen_string_literal: true

module RubyJard
  module Commands
    class FinishCommand < Pry::ClassCommand
      group "RubyJard"
      description "Finish into the execution of the current line"

      match "finish"

      banner <<-BANNER
      Usage: finish

      Finish into the execution of the current line

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
