require 'ruby_jard'

Thread.current.name = 'Main thread'
Thread.abort_on_exception = false
Thread.report_on_exception = false if Thread.respond_to?(:report_on_exception)

t0 = Thread.new { sleep }
t1 = Thread.new { return 1 }
t2 = Thread.new { raise 'Raised thread' }
t3 = Thread.new { sleep }
t3.kill
t4 = Thread.new { sleep }
t4.exit

sleep 0.5
jard

t0.kill
sleep 0.5

jard
a = 1
