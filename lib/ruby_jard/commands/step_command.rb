# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to Step into the execution of the current line.
    class StepCommand < BaseCommand
      include RubyJard::Commands::ValidationHelpers

      group 'RubyJard'
      description 'Step into the execution of the current line'
      match 'step'
      help_doc './step_command.doc.txt'

      def process
        times = validate_positive_integer!(args.first || 1)

        RubyJard::ControlFlow.dispatch(:step, times: times.to_i)
      end
    end
  end
end

RubyJard::PryProxy::Commands.add_command(RubyJard::Commands::StepCommand)
RubyJard::PryProxy::Commands.alias_command 's', 'step'
