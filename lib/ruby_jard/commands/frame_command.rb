# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to explore stacktrace.
    class FrameCommand < Pry::ClassCommand
      include RubyJard::Commands::ValidationHelpers

      group 'RubyJard'
      description 'Explore to any frame of current stacktrace.'

      match 'frame'

      banner <<-BANNER
      Usage: frame [FRAME_ID]

      Explore to any frame of current stacktrace.

      Examples:
        frame 4 # Jump to frame 4 in the backtrace
      BANNER

      def self.session_backtrace
        RubyJard.current_session.backtrace
      end

      def process
        frame = validate_present!(args.first)
        frame = validate_non_negative_integer!(frame)
        frame = validate_range!(frame, 0, self.class.session_backtrace.length - 1)
        RubyJard::ControlFlow.dispatch(:frame, frame: frame)
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::FrameCommand)
