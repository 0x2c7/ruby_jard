# frozen_string_literal: true
require 'ruby_jard'

class Test
  def initialize
    @index = 1
  end

  def process(index)
    a = index
    b = Thread.current[:index]
    sleep 0.1 until @index >= index
    jard
  end

  def start
    threads = (1..4).map do |index|
      Thread.new do
        Thread.current[:index] = index
        process(index)
      end
    end
    threads.map(&:join)
  end
end

Test.new.start
jard
sleep 0
