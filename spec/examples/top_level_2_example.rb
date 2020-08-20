# frozen_string_literal: true

require 'ruby_jard'

def quad(variable)
  double(variable)
end

def double(variable)
  variable * 2
end

jard
a = 1
b = double(a)
c = quad(a)
