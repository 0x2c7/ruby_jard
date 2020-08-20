require 'ruby_jard'

t = Thread.new { sleep }
t2 = Thread.new('Test thead 1') { sleep }
jard
a = 1
