# frozen_string_literal: true

module RubyJard
  module Commands
    class FrameCommand < Pry::ClassCommand
      group "RubyJard"
      description "Frame program execution."

      match "frame"

      banner <<-BANNER
      Usage: frame

      Frame program execution. The program will stop at the next breakpoint, or run until it finishes

      Examples:
        frame [TIMES]
      BANNER

      def process
        throw :control_flow, command: :frame, pry: pry_instance, options: {frame: args.first}
      end
    end
  end
end

Pry::Commands.add_command(RubyJard::Commands::FrameCommand)
