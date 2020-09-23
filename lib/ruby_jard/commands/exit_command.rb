# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to exit program execution.
    class ExitCommand < Pry::ClassCommand
      group 'RubyJard'
      description 'Exit program execution.'

      match 'exit'

      banner <<-BANNER
      Usage: exit
      Examples:
        exit

      Exit the execution of the program. Interally, when `jard` receives this command, it removes all debugging hooks, and triggers `::Kernel.exit`. Some long-running processes like `puma` or `sidekiq` may capture this event, treat it as an error, and recover to keep the processes running. In such cases, it's recommended to use `continue` command instead.
      BANNER

      def process
        RubyJard::ControlFlow.dispatch(:exit)
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::ExitCommand)
