# frozen_string_literal: true

class ListNode
  attr_accessor :val, :next

  def initialize(val, next_node = nil)
    @val = val
    @next = next_node
  end
end
