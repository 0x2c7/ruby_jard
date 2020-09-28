# frozen_string_literal: true

module RubyJard
  module Commands
    # Continue and skip one, or more next breakpoints.
    class SkipCommand < BaseCommand
      include RubyJard::Commands::ValidationHelpers

      group 'RubyJard'
      description 'Continue and skip one, or more next breakpoints.'
      match 'skip'
      help_doc './skip_command.doc.txt'

      def options(opt)
        opt.on :a, :all, 'Skip all breakpoints and continue til the end'
      end

      def process
        if opts[:all]
          RubyJard::ControlFlow.dispatch(:skip, times: -1)
        else
          times = validate_positive_integer!(args.first || 1)
          RubyJard::ControlFlow.dispatch(:skip, times: times.to_i)
        end
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::SkipCommand)
