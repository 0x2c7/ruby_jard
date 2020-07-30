# frozen_string_literal: true

module RubyJard
  module Commands
    ##
    # Helpers to help validate commands
    module ValidationHelpers
      def validate_positive_integer!(input)
        input = input.to_s.strip
        unless input =~ /^[+\-\d]+$/
          raise ::Pry::CommandError, '`argument is not an integer'
        end

        input = input.to_i
        raise ::Pry::CommandError, 'argument must be positive' if input <= 0

        input
      end

      def validate_non_negative_integer!(input)
        input = input.to_s.strip
        unless input =~ /^[+\-\d]+$/
          raise ::Pry::CommandError, 'argument is not an integer'
        end

        input = input.to_i
        raise ::Pry::CommandError, 'argument must be positive' if input < 0

        input.to_i
      end

      def validate_present!(input)
        input = input.to_s.strip
        if input.empty?
          raise ::Pry::CommandError, 'argument must be present'
        end

        input
      end

      def validate_range!(input, from, to)
        if input < from || input > to
          raise ::Pry::CommandError, "argument must be from #{from} to #{to}"
        end

        input
      end
    end
  end
end
