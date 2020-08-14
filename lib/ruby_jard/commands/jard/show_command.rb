# frozen_string_literal: true

module RubyJard
  module Commands
    ##
    # Show a screen
    class ShowCommand < Pry::ClassCommand
      description 'Show a screen'
      banner <<-BANNER
        Usage: jard show [-h] [screen]
      BANNER

      def self.screens
        RubyJard::Screens.names
      end

      def self.enabled_screens
        RubyJard.config.enabled_screens
      end

      def process
        screen = args.first.to_s.strip

        if screen.empty?
          raise Pry::CommandError,
                "Please input one of the following: #{self.class.screens.join(', ')}"
        end

        unless self.class.screens.include?(screen)
          raise Pry::CommandError,
                "Screen `#{screen}` not found. Please input one of the following: #{self.class.screens.join(', ')}"
        end

        self.class.enabled_screens << screen
        self.class.enabled_screens.uniq!

        RubyJard::ControlFlow.dispatch(:list)
      end
    end
  end
end
