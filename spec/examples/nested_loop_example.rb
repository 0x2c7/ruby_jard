# frozen_string_literal: true

require 'ruby_jard'

class DummyCalculator
  def calculate(n)
    10.times do |index_a|
      a = 10
      5.times do |index_b|
        b = 'This is sparta'
        1.times do |index_c|
          jard
          c = n + index_a + index_b + index_c
        end
      end
    end
  end
end

DummyCalculator.new.calculate(10)
