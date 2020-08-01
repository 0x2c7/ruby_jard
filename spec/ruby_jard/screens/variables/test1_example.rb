# frozen_string_literal: true

require 'ruby_jard'

var_a = 123
var_b = 'hello world'
var_c = ['Hello', 1, 2, 3]
variable_d = { test: 1, this: 'Bye', array: nil }
variable_e = /Wait, what/i
variable_f = 1.1
variable_g = 99..100

jard
variable_h = 15

jard
1.times {}

jard
var_a + variable_f + variable_h || 5
