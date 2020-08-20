# frozen_string_literal: true

require 'ruby_jard'

Thread.current.name = 'Main thread'

Thread.new { sleep }
t1 = Thread.new { sleep }
t1.name = 'Test 1'
t2 = Thread.new { sleep }
t2.name = 'Test 2'

sleep 0.5

jard

t3 = Thread.new { sleep }
t3.name = 'Test 3'

sleep 0.5
jard

t1.name = 'Test 3'

jard
1
