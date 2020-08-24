require 'ruby_jard'
require 'jard_merge_sort'
require 'securerandom'
require_relative '../../examples/dummy_heap.rb'

jard
sorter = JardMergeSort::Sorter.new([1, 2, 3, 4, 5])
result_a = sorter.sort { |a, b| a < b }
result_b = sorter.sort { |a, b| a > b }
result_c = sorter.sort { |a, b| a < b }
result_d = sorter.sort { |a, b| SecureRandom.uuid  < SecureRandom.uuid }
result_e = sorter.sort { |a, b| SecureRandom.uuid  < SecureRandom.uuid }
heap = Heap.new
heap.push(1)
heap.push(2)
heap.push(3)
heap.push(SecureRandom.uuid)
