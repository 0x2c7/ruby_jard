# frozen_string_literal: true

module RubyJard
  module Commands
    # Command used to explore stacktrace.
    # Data attached in the throw:
    # * command: constant symbol (:frame)
    # * pry: current context pry instance
    # * frame (optional): frame id of the destination frame
    class FrameCommand < Pry::ClassCommand
      group 'RubyJard'
      description 'Explore to any frame of current stacktrace.'

      match 'frame'

      banner <<-BANNER
      Usage: frame

      Explore to any frame of current stacktrace.

      Examples:
        frame [FRAME_ID]
      BANNER

      def process
        throw :control_flow,
              command: :frame,
              pry: pry_instance,
              # TODO: Remove redundant options
              options: { frame: args.first }
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::FrameCommand)
