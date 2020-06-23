# frozen_string_literal: true

module RubyJard
  module Commands
    class UpCommand < Pry::ClassCommand
      group "RubyJard"
      description "Up into the execution of the current line"

      match "up"

      banner <<-BANNER
      Usage: up

      Up into the execution of the current line

      Examples:
        up
      BANNER

      def process
        throw :control_flow, command: :up, pry: pry_instance
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::UpCommand)
