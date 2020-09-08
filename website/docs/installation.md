---
id: Installation
---

**Warning**: Ruby Jard is still under heavy development. Bugs and weird behaviors are expected. If you see one, please don't hesitate to open an issue. I'll try my best to fix.

Add `ruby_jard` to your Gemfile, recommend to put it in test or development environment.

```ruby
gem 'ruby_jard'
```

Add magic method `jard` before the line you want to debug, just like `byebug`

```ruby
def test_method
  a = 1
  b = 2
  jard # Debugger will stop here
  c = a + b
end
```
