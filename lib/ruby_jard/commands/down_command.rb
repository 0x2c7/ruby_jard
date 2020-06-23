# frozen_string_literal: true

module RubyJard
  module Commands
    class DownCommand < Pry::ClassCommand
      group "RubyJard"
      description "Down into the execution of the current line"

      match "down"

      banner <<-BANNER
      Usage: down

      Down into the execution of the current line

      Examples:
        down
      BANNER

      def process
        throw :control_flow, command: :down, pry: pry_instance
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::DownCommand)
