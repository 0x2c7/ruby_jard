# frozen_string_literal: true

module RubyJard
  ##
  # A helper to standardize control instruction passed around via
  # throw and catch mechanism.
  class ControlFlow
    THROW_KEYWORD = :jard_control_flow
    ALLOW_LIST = {
      continue: [:times], # lib/ruby_jard/commands/continue_command.rb
      frame: [:frame],    # lib/ruby_jard/commands/frame_command.rb
      up: [:times],       # lib/ruby_jard/commands/up_command.rb
      down: [:times],     # lib/ruby_jard/commands/down_command.rb
      next: [:times],     # lib/ruby_jard/commands/next_command.rb
      step: [:times]      # lib/ruby_jard/commands/step_command.rb
    }.freeze

    attr_reader :command, :arguments

    def initialize(command, arguments)
      @command = command
      @arguments = arguments

      validate!
    end

    def validate!
      if command.to_s.empty?
        raise RubyJard::Error, 'Control command is empty'
      end

      unless ALLOW_LIST.key?(command)
        raise RubyJard::Error,
              "Control command `#{command}` is not registered in the allow list."
      end

      invalid_keys = arguments.keys - ALLOW_LIST[command]
      unless invalid_keys.empty?
        raise RubyJard::Error,
              "Control command `#{command}` is attached with unregister arguments: #{invalid_keys}"
      end
    end

    class << self
      def dispatch(command, arguments = {})
        if command.is_a?(RubyJard::ControlFlow)
          throw THROW_KEYWORD, command
        else
          throw THROW_KEYWORD, new(command, arguments)
        end
      end

      def listen
        raise RubyJard::Error, 'This method requires a block' unless block_given?

        flow = catch(THROW_KEYWORD) do
          yield
          nil
        end

        if flow.nil? || flow.is_a?(RubyJard::ControlFlow)
          flow
        else
          raise RubyJard::Error, 'Control flow misused!'
        end
      end
    end
  end
end
