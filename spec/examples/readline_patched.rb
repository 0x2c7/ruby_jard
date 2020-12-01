# frozen_string_literal: true

require 'reline'
require 'ruby_jard'

Readline = Reline

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
