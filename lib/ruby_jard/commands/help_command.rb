# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to exit program execution.
    class HelpCommand < Pry::Command::Help
      include RubyJard::Commands::ColorHelpers

      group 'Help'
      description 'Display help'
      match 'help'

      def options(opt)
        opt.on :a, :all, 'List all available commands'
      end

      def process
        if opts[:a]
          display_banner
          display_index(command_groups)
        elsif args.empty?
          display_welcome
        else
          display_search(args.first)
        end
        output.puts "\n"
      end

      def help_text_for_commands(name, commands)
        "#{highlight(bold(name.capitalize))}\n" + commands.map do |command|
          "  #{command.options[:listing].to_s.ljust(18)} " \
          "#{command.description.capitalize}"
        end.join("\n")
      end

      def group_sort_key(group_name)
        [
          %w[
            Help RubyJard Context Editing Introspection Input_and_output Navigating_pry
            Gems Basic Commands
          ].index(group_name.tr(' ', '_')) || 99, group_name
        ]
      end

      def display_welcome
        display_banner
        output.puts "REPL Ruby Jard's REPL engine is powered by Pry, a runtime developer console with powerful "\
          'introspection capabilities. Those are the most common commands to control program flow:'
        output.puts "\n"

        jard_commands = visible_commands.values.select { |command| command.group == 'RubyJard' }
        output.puts help_text_with_sub_commands(jard_commands)
        output.puts "\n"
        output.puts 'To display all commands, please use ' + highlight('help -a')
      end

      def display_banner
        banner = <<~'BANNER'
          ______      _               ___               _
          | ___ \    | |             |_  |             | |
          | |_/ /   _| |__  _   _      | | __ _ _ __ __| |
          |    / | | | '_ \| | | |     | |/ _` | '__/ _` |
          | |\ \ |_| | |_) | |_| | /\__/ / (_| | | | (_| |
          \_| \_\__,_|_.__/ \__, | \____/ \__,_|_|  \__,_|
                             __/ |
                            |___/
        BANNER
        output.puts highlight(banner)
        output.puts "\n"
        output.puts highlight('Just Another Ruby Debugger')
        output.puts "\n"
        output.puts 'Ruby Jard provides a rich Terminal UI that visualizes everything your need, '\
          'navigates your program with pleasure, stops at matter places only, reduces manual and '\
          'mental efforts. You can now focus on real debugging. If this is the first time you use '\
          'Ruby Jard, I recommend reading the documentation '\
          'page to get started: ' + highlight('https://rubyjard.org/docs/')
        output.puts "\n"
      end

      def help_text_with_sub_commands(commands)
        commands.map do |command|
          text = []
          text << "  #{command.options[:listing].to_s.ljust(18)} " \
          "#{command.description.capitalize}"
          sub_commands = command.new.slop.instance_variable_get(:@commands)
          sub_commands.each do |name, sub_command|
            text << "    ▸ #{name.to_s.ljust(18)} #{sub_command.description.capitalize}"
          end
          text
        end.flatten.join("\n")
      end
    end
  end
end

RubyJard::PryProxy::Commands.add_command(RubyJard::Commands::HelpCommand)
