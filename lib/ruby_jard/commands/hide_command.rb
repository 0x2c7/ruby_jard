# frozen_string_literal: true

module RubyJard
  module Commands
    ##
    # Show a screen
    class HideCommand < BaseCommand
      group 'RubyJard'
      description 'Hide a screen'
      match 'hide'
      help_doc './hide_command.doc.txt'

      def initialize(context = {})
        super(context)

        @screens = context[:screens] || RubyJard::Screens
        @config = context[:config] || RubyJard.config
      end

      def process
        screen = args.first.to_s.strip

        if screen.empty?
          raise Pry::CommandError,
                "Please input one of the following: #{@screens.names.join(', ')}"
        end

        unless @screens.names.include?(screen)
          raise Pry::CommandError,
                "Screen `#{screen}` not found. Please input one of the following: #{@screens.names.join(', ')}"
        end

        new_enabled_screens = @config.enabled_screens.dup
        new_enabled_screens.delete(screen)
        new_enabled_screens.uniq!
        @config.enabled_screens = new_enabled_screens

        RubyJard::ControlFlow.dispatch(:list)
      end
    end
  end
end
