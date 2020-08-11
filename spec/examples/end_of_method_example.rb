# frozen_string_literal: true

require 'ruby_jard'

class DummyCalculator
  def calculate(n)
    1.times do |index_c|
      n += index_c + 1
      jard
    end
    jard
  end
end

DummyCalculator.new.calculate(10)
