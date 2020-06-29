# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to explore stacktrace.
    # Data attached in the throw:
    # * command: constant symbol (:down)
    # * pry: current context pry instance
    class DownCommand < Pry::ClassCommand
      group 'RubyJard'
      description 'Explore the frames bellow the current stopped line in the backtrace'

      match 'down'

      banner <<-BANNER
      Usage: down

      Explore the frames bellow the current stopped line in the backtrace.

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
