require 'ruby_jard'

require_relative './merge_k_sorted_list.rb'

list_a = ListNode.new(
  4, ListNode.new(
    5, ListNode.new(
      7, ListNode.new(
        9, ListNode.new(
          10
        )
      )
    )
  )
)

list_b = ListNode.new(
  3, ListNode.new(
    7, ListNode.new(
      9
    )
  )
)

list_c = ListNode.new(
  1, ListNode.new(
    2, ListNode.new(
      2, ListNode.new(
        6
      )
    )
  )
)

jard
result_list = MergeKSortedList.call([list_a, list_b, list_c])
result = []

until result_list.nil?
  result << result_list.val
  result_list = result_list.next
end

jard
# [1, 2, 2, 3, 4, 5, 6, 7, 7, 9, 9, 10]
puts result
