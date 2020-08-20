require 'ruby_jard'

Thread.current.name = 'Main thread'
Thread.abort_on_exception = false
Thread.report_on_exception = false if Thread.respond_to?(:report_on_exception)

def thread_sleep
  sleep
end

def spawn_threads
  3.times do |index|
    t = Thread.new { sleep }
    t.name = "New thread #{index}"
  end
end

t0 = Thread.new { thread_sleep }

sleep 0.5
jard

t1 = Thread.new { spawn_threads; sleep }

sleep 0.5
jard
a = 1
