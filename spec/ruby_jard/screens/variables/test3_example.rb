# frozen_string_literal: true

require 'ruby_jard'

class Fibonaci
  def calculate(n); end
end

class FibonaciCalculator
  A_USELESS_CONSTANT = '123'

  def self.init
    @root = 'testing jard'
  end

  def self.calculate(n)
    m = n * 2 - n
    jard
    Fibonaci.new.calculate(m)
  end
end

FibonaciCalculator.init
FibonaciCalculator.calculate(10)
