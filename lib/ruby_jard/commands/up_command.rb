# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to explore stacktrace.
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
        RubyJard::ControlFlow.dispatch(:up)
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::UpCommand)
