require 'ruby_jard'

def test(n, text)
  n.times { |index| puts "#{n} | #{index}: #{text}" }
end
jard
test(10, 'abcdef')
test(100, 'xyz')
jard
1
