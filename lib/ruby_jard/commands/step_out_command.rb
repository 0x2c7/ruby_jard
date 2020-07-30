# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to Step into the execution of the current line.
    class StepOutCommand < Pry::ClassCommand
      include RubyJard::Commands::ValidationHelpers

      group 'RubyJard'
      description 'Step out of current frame and move to the execution of the upper frame'

      match 'step-out'

      banner <<-BANNER
        Usage: step-out [times]
        Examples:
          step-out
          step-out 1
          step-out 7

        Step out of current frame and move to the execution of the upper frame.
      BANNER

      def process
        times = args.first || 1
        validate_integer!(times)

        RubyJard::ControlFlow.dispatch(:step_out, times: times.to_i)
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::StepOutCommand)
Pry::Commands.alias_command 'so', 'step-out'
