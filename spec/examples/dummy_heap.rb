# frozen_string_literal: true

class Heap
  def initialize
    @storage = []
  end

  def pop
    @storage.shift
  end

  def push(node)
    @storage.unshift(node)
  end
end
