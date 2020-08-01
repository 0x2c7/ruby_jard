# frozen_string_literal: true

require 'ruby_jard'

class Fibonaci
  MAX_SUPPORTED = 64

  def initialize
    @a = 1
    @b = 1
    @other = 5
  end

  def calculate(n)
    raise 'Exceeded support max' if n > MAX_SUPPORTED

    return @a if n == 1
    return @b if n == 2

    (3..n).each do |index|
      puts index
      jard
      k = @a + @b
      @a = @b
      @b = k
    end

    @b
  end
end

Fibonaci.new.calculate(50)
