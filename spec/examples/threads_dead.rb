# frozen_string_literal: true

require 'ruby_jard'

Thread.current.name = 'Main thread'
Thread.abort_on_exception = false
Thread.report_on_exception = false if Thread.respond_to?(:report_on_exception)

t1 = Thread.new { sleep }
Thread.new { return 1 }
Thread.new { raise 'Raised thread' }
t2 = Thread.new { sleep }
t2.kill
t3 = Thread.new { sleep }
t3.exit

sleep 0.5
jard

t1.kill
sleep 0.5

jard
1
