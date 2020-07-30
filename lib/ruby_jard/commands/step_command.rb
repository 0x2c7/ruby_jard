# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to Step into the execution of the current line.
    class StepCommand < Pry::ClassCommand
      include RubyJard::Commands::ValidationHelpers

      group 'RubyJard'
      description 'Step into the execution of the current line'

      match 'step'

      banner <<-BANNER
        Usage: step [times]
        Examples:
          step
          step 1
          step 7

        Step into the execution of the current line.
      BANNER

      def process
        times = args.first || 1
        validate_integer!(times)

        RubyJard::ControlFlow.dispatch(:step, times: times.to_i)
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::StepCommand)
Pry::Commands.alias_command 's', 'step'
