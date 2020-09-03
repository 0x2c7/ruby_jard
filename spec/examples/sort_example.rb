require 'ruby_jard'
require 'jard_merge_sort'
require 'securerandom'

sorter = JardMergeSort::Sorter.new([1, 2, 3, 4, 5, 6, 7, 8])
jard
result_a = sorter.sort { |a, b| a < b }
jard
10.times { sorter.sort { |a, b| SecureRandom.random_bytes  < SecureRandom.random_bytes } }
