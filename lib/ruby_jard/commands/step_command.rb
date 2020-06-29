# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to Step into the execution of the current line.
    # Data attached in the throw:
    # * command: constant symbol (:step)
    # * pry: current context pry instance
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
        throw :control_flow, command: :step, pry: pry_instance
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::StepCommand)
