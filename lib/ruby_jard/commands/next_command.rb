# frozen_string_literal: true

module RubyJard
  module Commands
    class NextCommand < Pry::ClassCommand
      group "RubyJard"
      description "Next into the execution of the current line"

      match "next"

      banner <<-BANNER
      Usage: next

      Next into the execution of the current line

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
