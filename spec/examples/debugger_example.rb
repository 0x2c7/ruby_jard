# frozen_string_literal: true

require 'ruby_jard'

class SubCalculator
  def calculate(d)
    d1 = d * 2
    d2 = d * 2
    d1 + d2
  end
end

class Calculator
  def calculate(a, b, c)
    d = a + b
    debugger
    e = SubCalculator.new.calculate(d)
    debugger
    e + c
  end
end

Calculator.new.calculate(1, 2, 3)
