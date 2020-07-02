# frozen_string_literal: true

module RubyJard
  module Templates
    ##
    # Template for a row. Each screen has only 1 template for row. Each row includes multiple columns.
    class RowTemplate
      attr_reader :columns

      def initialize(columns: [])
        @columns = columns
      end

      def priorities
        columns.flat_map do |column|
          column.spans.flat_map(&:priority)
        end.uniq.compact.sort.reverse
      end
    end
  end
end
