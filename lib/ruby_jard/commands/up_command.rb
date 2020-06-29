# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to explore stacktrace.
    # Data attached in the throw:
    # * command: constant symbol (:up)
    # * pry: current context pry instance
    class UpCommand < Pry::ClassCommand
      group 'RubyJard'
      description 'Explore the frames above the current stopped line in the backtrace'

      match 'up'

      banner <<-BANNER
      Usage: up

      Explore the frames above the current stopped line in the backtrace.

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
