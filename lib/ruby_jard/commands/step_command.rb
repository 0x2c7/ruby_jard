# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to Step into the execution of the current line.
    class StepCommand < Pry::ClassCommand
      group 'RubyJard'
      description 'Step into the execution of the current line'

      match 'step'

      banner <<-BANNER
        Usage: step

        Step into the execution of the current line

        Examples:
          step
      BANNER

      def process
        RubyJard::ControlFlow.dispatch(:step)
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::StepCommand)
