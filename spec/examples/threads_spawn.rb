# frozen_string_literal: true

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

Thread.new { thread_sleep }

sleep 0.5
jard

Thread.new { spawn_threads and sleep }

sleep 0.5
jard
1
