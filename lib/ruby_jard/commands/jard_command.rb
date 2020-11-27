# frozen_string_literal: true

require 'ruby_jard/commands/show_command'
require 'ruby_jard/commands/hide_command'
require 'ruby_jard/commands/color_scheme_command'
require 'ruby_jard/commands/output_command'
require 'ruby_jard/commands/filter_command'

module RubyJard
  module Commands
    # Command used to explore stacktrace.
    class JardCommand < Pry::ClassCommand
      group 'RubyJard'
      description 'Command to control jard configurations'

      match 'jard'

      banner <<-BANNER
        Usage: jard [-h] [sub commands]
      BANNER

      SUB_COMMANDS = {
        'show' => RubyJard::Commands::ShowCommand,
        'hide' => RubyJard::Commands::HideCommand,
        'color-scheme' => RubyJard::Commands::ColorSchemeCommand,
        'output' => RubyJard::Commands::OutputCommand,
        'filter' => RubyJard::Commands::FilterCommand
      }.freeze

      def subcommands(cmd)
        SUB_COMMANDS.each do |command_name, sub_command|
          cmd.command command_name do |opt|
            opt.description sub_command.description
            opt.run do |_, arguments|
              @ran_sub_command = true
              sub_command.new(context).send(:call_safely, *arguments)
            end
          end
        end
      end

      def process
        return if @ran_sub_command
        return if ['-h', '--help'].include?(args.first) || SUB_COMMANDS.keys.include?(args.first)

        pry_instance.output.puts help
      end
    end
  end
end

RubyJard::PryProxy::Commands.add_command(RubyJard::Commands::JardCommand)
