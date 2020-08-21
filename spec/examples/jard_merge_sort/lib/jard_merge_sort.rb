# frozen_string_literal: true

require 'jard_merge_sort/version'
require 'jard_merge_sort/merger'

module JardMergeSort
  ##
  # Entry point for merge sort algorithm
  class Sorter
    def initialize(array)
      @array = array
      @merger = JardMergeSort::Merger.new
    end

    def sort(&less)
      do_sort(@array, less)
    end

    private

    def do_sort(array, less)
      return [] if array.empty?
      return [array.first] if array.length == 1

      mid = array.length / 2
      sorted_left = do_sort(array[0..mid - 1], less)
      sorted_right = do_sort(array[mid..array.length - 1], less)
      @merger.merge(sorted_left, sorted_right, less)
    end
  end
end
