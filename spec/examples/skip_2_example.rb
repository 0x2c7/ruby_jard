require 'ruby_jard'

def test(count)
  jard
  puts 'Test1'
  test2(count - 1) if count > 0
end

def test2(count)
  jard
  puts 'Test2'
  test(count - 1) if count > 0
end

test(50)
jard
puts 'End'
