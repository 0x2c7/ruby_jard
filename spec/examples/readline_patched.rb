# frozen_string_literal: true

require 'reline'
require 'ruby_jard'

Readline.singleton_class.prepend(Module.new { def input=(i) super end })

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
