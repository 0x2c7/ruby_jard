# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to explore stacktrace.
    class DownCommand < Pry::ClassCommand
      include RubyJard::Commands::ValidationHelpers

      group 'RubyJard'
      description 'Explore the frames bellow the current stopped line in the backtrace'

      match 'down'

      banner <<-BANNER
      Usage: down [-h] [times]
      Examples:
        down
        down 1
        down 7

      Explore the frames bellow the current stopped line in the backtrace. All the C frames will be skipped.
      BANNER

      def process
        times = args.first || 1
        validate_integer!(times)

        RubyJard::ControlFlow.dispatch(:down, times: times.to_i)
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::DownCommand)
