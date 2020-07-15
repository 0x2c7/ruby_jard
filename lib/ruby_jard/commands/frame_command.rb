# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to explore stacktrace.
    class FrameCommand < Pry::ClassCommand
      group 'RubyJard'
      description 'Explore to any frame of current stacktrace.'

      match 'frame'

      banner <<-BANNER
      Usage: frame [FRAME_ID]

      Explore to any frame of current stacktrace.

      Examples:
        frame 4 # Jump to frame 4 in the backtrace
      BANNER

      def process
        frame = args.first
        raise Pry::CommandError, 'Frame ID is required' if frame.nil?
        raise Pry::CommandError, 'Frame ID must be numeric' unless frame =~ /^\d+$/i

        frame = frame.to_i
        if frame >= RubyJard.current_session.backtrace.length || frame < 0
          raise Pry::CommandError, "Frame #{frame} does not exist!"
        else
          RubyJard::ControlFlow.dispatch(:frame, frame: args.first)
        end
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::FrameCommand)
