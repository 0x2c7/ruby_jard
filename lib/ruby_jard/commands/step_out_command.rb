# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to Step into the execution of the current line.
    class StepOutCommand < BaseCommand
      include RubyJard::Commands::ValidationHelpers

      group 'RubyJard'
      description 'Step out of current frame and move to the execution of the upper frame'
      match 'step-out'
      help_doc './step_out_command.doc.txt'

      def process
        times = validate_positive_integer!(args.first || 1)

        RubyJard::ControlFlow.dispatch(:step_out, times: times.to_i)
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::StepOutCommand)
Pry::Commands.alias_command 'so', 'step-out'
