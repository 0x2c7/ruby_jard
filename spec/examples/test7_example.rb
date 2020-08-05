require 'ruby_jard'

code1 = <<~CODE
  def test1(a, b)
    c = a + b
    c * 2
  end
CODE

code2 = <<~CODE, nil, __FILE__, __LINE__ + 1
  def test2(a, b)
    c = a + b
    c * 3
  end
CODE

eval(code1)
eval(*code2)

jard
test1(1, 2)
test2(3, 4)
