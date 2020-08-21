require 'ruby_jard'
require 'jard_merge_sort'

jard
sorter = JardMergeSort::Sorter.new([1, 2, 3, 4, 5])
result_a = sorter.sort { |a, b| a < b }
result_b = sorter.sort { |a, b| a > b }
puts result_a
puts result_b
