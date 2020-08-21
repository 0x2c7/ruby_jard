# frozen_string_literal: true

class Heap
  def initialize
    @storage = []
    @length = 0
  end

  def pop
    return nil if @length <= 0

    swap(0, @length - 1)
    @length -= 1
    heap_down(0)
    @storage[@length]
  end

  def push(node)
    @length += 1
    @storage[@length - 1] = node
    heap_up(@length - 1)
  end

  def heap_down(position)
    while position < @length
      min_pos = find_min_pos(position, position * 2 + 1, position * 2 + 2)
      return if min_pos == position

      swap(position, min_pos)
      position = min_pos
    end
  end

  def heap_up(position)
    while position > 0
      parent = (position - 1) / 2
      return if parent < 0 || @storage[parent].val <= @storage[position].val

      swap(parent, position)
      position = parent
    end
  end

  def find_min_pos(a, b, c)
    min = a
    min = b if b < @length && @storage[b].val < @storage[min].val
    min = c if c < @length && @storage[c].val < @storage[min].val
    min
  end

  def swap(a, b)
    tmp = @storage[a]
    @storage[a] = @storage[b]
    @storage[b] = tmp
  end
end
