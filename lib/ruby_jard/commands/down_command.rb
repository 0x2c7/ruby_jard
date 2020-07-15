# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to explore stacktrace.
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
        RubyJard::ControlFlow.dispatch(:down)
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::DownCommand)
