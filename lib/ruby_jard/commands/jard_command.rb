# frozen_string_literal: true

require 'ruby_jard/commands/jard/show_command'
require 'ruby_jard/commands/jard/hide_command'
require 'ruby_jard/commands/jard/color_scheme_command'

module RubyJard
  module Commands
    # Command used to explore stacktrace.
    class JardCommand < Pry::ClassCommand
      group 'RubyJard'
      description 'Show all current program output'

      match 'jard'

      banner <<-BANNER
        Usage: jard [-h] [sub commands]
      BANNER

      def subcommands(cmd)
        cmd.command :show do |opt|
          opt.description 'Show a particular screen'
          opt.run do |_, arguments|
            RubyJard::Commands::ShowCommand.new(context).send(:call_safely, *arguments)
          end
        end

        cmd.command :hide do |opt|
          opt.description 'Hide a particular screen'
          opt.run do |_, arguments|
            RubyJard::Commands::HideCommand.new(context).send(:call_safely, *arguments)
          end
        end

        cmd.command 'color-scheme' do |opt|
          opt.description 'Blah blah'
          opt.run do |_, arguments|
            RubyJard::Commands::ColorSchemeCommand.new(context).send(:call_safely, *arguments)
          end
        end
      end

      def process; end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::JardCommand)
