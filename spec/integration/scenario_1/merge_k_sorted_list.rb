# frozen_string_literal: true

require_relative './list_node'
require_relative './heap'

# https://leetcode.com/problems/merge-k-sorted-lists
class MergeKSortedList
  def self.call(lists)
    heap = Heap.new
    lists.each do |head|
      heap.push(head) if head
    end

    final_head = nil
    final_tail = nil

    loop do
      jard
      node = heap.pop
      break if node.nil?

      heap.push(node.next) if node.next

      if final_tail.nil?
        final_head = final_tail = ListNode.new(node.val)
      else
        new_node = ListNode.new(node.val)
        final_tail.next = new_node
        final_tail = new_node
      end
    end
    final_head
  end
end
