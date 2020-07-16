# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to Step into the execution of the current line.
    class StepOutCommand < Pry::ClassCommand
      group 'RubyJard'
      description 'Step out of current frame and move to the execution of the upper frame'

      match 'step-out'

      banner <<-BANNER
        Usage: step-out

        Step out of current frame and move to the execution of the upper frame

        Examples:
          step-out
      BANNER

      def process
        RubyJard::ControlFlow.dispatch(:step_out)
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::StepOutCommand)
