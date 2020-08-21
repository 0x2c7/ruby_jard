# frozen_string_literal: true

module JardMergeSort
  class Merger
    def merge(left, right, less)
      result = []

      while !left.empty? || !right.empty?
        result <<
          if left.empty?
            right.shift
          elsif right.empty?
            left.shift
          elsif less.call(left[0], right[0])
            left.shift
          else
            right.shift
          end
      end

      result
    end
  end
end
