# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to explore stacktrace.
    class UpCommand < Pry::ClassCommand
      include RubyJard::Commands::ValidationHelpers

      group 'RubyJard'
      description 'Explore the frames above the current stopped line in the backtrace'

      match 'up'

      banner <<-BANNER
      Usage: up [-h] [times]
      Examples:
        up
        up 1
        up 7

      Explore the frames above the current stopped line in the backtrace. All the C frames will be skipped.
      BANNER

      def process
        times = args.first || 1
        validate_integer!(times)

        RubyJard::ControlFlow.dispatch(:up, times: times.to_i)
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::UpCommand)
