# frozen_string_literal: true

require 'readline'
require 'ruby_jard'

class Calculator
  def calculate(a, b, c)
    jard
    d = a + b
    jard
    e = d + 10
    jard
    e + c
  end
end

Calculator.new.calculate(1, 2, 3)
