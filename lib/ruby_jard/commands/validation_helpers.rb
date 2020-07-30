# frozen_string_literal: true

module RubyJard
  module Commands
    ##
    # Helpers to help validate commands
    module ValidationHelpers
      def validate_integer!(input)
        input = input.to_s.strip
        unless input =~ /^\d+$/
          raise ::Pry::CommandError, "`#{input}` is not an integer"
        end
      end
    end
  end
end
