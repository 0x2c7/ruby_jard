# frozen_string_literal: true

module RubyJard
  ##
  # Feed a custom escape sequence into Repl, then detect and parse
  # to dispatch captured command.
  class ReplSequence
    COMMAND_ESCAPE_SEQUENCE_PREFIX = '\e]711;Command~'
    COMMAND_ESCAPE_SEQUENCE_SUFFIX = ';'
    COMMAND_ESCAPE_SEQUENCE_REGEXP = /\\e\]711;Command~([a-z\-\ ]*);/.freeze

    def self.encode(command)
      if command.nil? || command.empty?
        ''
      else
        "#{COMMAND_ESCAPE_SEQUENCE_PREFIX}#{command}#{COMMAND_ESCAPE_SEQUENCE_SUFFIX}"
      end
    end

    def self.detect(content)
      matches = COMMAND_ESCAPE_SEQUENCE_REGEXP.match(content)
      if matches.nil?
        nil
      else
        matches[1]
      end
    end
  end
end
