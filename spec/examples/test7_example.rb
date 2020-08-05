require 'ruby_jard'

eval(
  <<~CODE
    def test1(a, b)
      c = a + b
      c * 2
    end
  CODE
)
eval(
  <<~CODE, nil, __FILE__, __LINE__ + 1
    def test2(a, b)
      c = a + b
      c * 3
    end
  CODE
)

jard
test1(1, 2)
test2(3, 4)
