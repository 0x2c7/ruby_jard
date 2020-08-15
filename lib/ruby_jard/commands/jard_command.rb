# frozen_string_literal: true

require 'ruby_jard/commands/jard/show_command'
require 'ruby_jard/commands/jard/hide_command'
require 'ruby_jard/commands/jard/color_scheme_command'
require 'ruby_jard/commands/jard/output_command'

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

      SUB_COMMANDS = {
        'show' => RubyJard::Commands::ShowCommand,
        'hide' => RubyJard::Commands::HideCommand,
        'color-scheme' => RubyJard::Commands::ColorSchemeCommand,
        'output' => RubyJard::Commands::OutputCommand
      }.freeze

      def subcommands(cmd)
        SUB_COMMANDS.each do |command_name, sub_command|
          cmd.command command_name do |opt|
            opt.description sub_command.description
            opt.run do |_, arguments|
              sub_command.new(context).send(:call_safely, *arguments)
            end
          end
        end
      end

      def process; end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::JardCommand)
