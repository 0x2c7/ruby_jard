# frozen_string_literal: true

module RubyJard
  module Commands
    ##
    # Helpers to help validate commands
    module ValidationHelpers
      def validate_positive_integer!(input)
        input = input.to_s.strip
        unless input =~ /^[+\-\d]+$/
          raise ::Pry::CommandError, "`#{input}` is not an integer"
        end

        input = input.to_i
        raise ::Pry::CommandError, "`#{input}` must be positive" if input <= 0

        input
      end
    end
  end
end
