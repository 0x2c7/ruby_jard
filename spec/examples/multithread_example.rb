# frozen_string_literal: true
require 'ruby_jard'

def process(index)
  a = index
  b = Thread.current[:index]
  jard if index % 2 == 0
end

threads = (1..4).map do |index|
  Thread.new do
    Thread.current[:index] = index
    process(index)
    sleep 0.5
  end
end
threads.map(&:join)
