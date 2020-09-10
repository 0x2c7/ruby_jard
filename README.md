[<img src="./website/static/img/logo/logo-full.png" width="400" />](https://rubyjard.org/)

[![From Vietnam with <3](https://raw.githubusercontent.com/webuild-community/badge/master/svg/love.svg)](https://webuild.community)
![Rspec](https://github.com/nguyenquangminh0711/ruby_jard/workflows/Rspec/badge.svg?branch=master)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop-hq/rubocop)

Ruby Jard provides a rich Terminal UI that visualizes everything your need, navigates your program with pleasure, stops at matter places only, reduces manual and mental efforts. You can now focus on real debugging.

Please visit [https://rubyjard.org/](https://rubyjard.org/) for more information.

[![RubyJard Demo](https://asciinema.org/a/358874.svg)](https://asciinema.org/a/358874)

*[(Click for demo video)](https://asciinema.org/a/358874)*

**Note**: Ruby Jard is still under heavy development. Bugs and weird behaviors are expected. If you see one, please don't hesitate to [open an issue](https://github.com/nguyenquangminh0711/ruby_jard/issues). I'll try my best to fix.

## Install Ruby Jard

### Bundler

Add one of those lines into your Gemfile. **Note**: Ruby Jard is discouraged to use on production environment.

```ruby
gem 'ruby_jard', group: :development
```

```bash
❯ bundle install
```

If you would like to use Ruby Jard to debug a test, you can add to group test too.


```ruby
gem 'ruby_jard', group: [:development, :test]
```

If you would like to use edged developing version of Ruby Jard:

```ruby
gem 'ruby_jard', group: :development, git: 'https://github.com/nguyenquangminh0711/ruby_jard'
```

### Ruby Gem

If you want to install Ruby Jard independently from bundler:

```bash
gem install ruby_jard
```

If you want to install a specific version published on [Ruby gems](https://rubygems.org/gems/ruby_jard):

```bash
gem install ruby_jard@0.2.3
```

## Run your program with Ruby Jard

![How to run your program with Ruby Jard](./website/static/img/getting_started/how-to-use.gif)

To use Ruby Jard, you just need to put `jard` magic method **before** any places you want to stop. Jard supports stopping at anywhere, including top level binding, instance methods, class methods, string evaluation, or even inside a class declaration.

```ruby
def test_method(input)
  a = 1
  b = 2
  jard # Debugger will stop here
  c = a + b + input
end

class TestClass
  jard # Yes, it can stop here too
  @dirty_class_method = 1 + 1

  def test_method
    jard
  end

  def self.test_class_method
    jard
  end
end

jard
test_method(5)
```

Afterward, run your program, just like normally. If your program meets `jard` execution break point, it gonna stop, show the UI, and let you debug.

In case you meet error `undefined local variable or method jard`, please require ruby_jard manually at initializing scripts. If you use Ruby Jard with famous frameworks, ruby_jard will be loaded by default

```ruby
require 'ruby_jard'
```

Please visit [https://rubyjard.org/](https://rubyjard.org/) for more information.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nguyenquangminh0711/ruby_jard. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/nguyenquangminh0711/ruby_jard/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RubyJard project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/ruby_jard/blob/master/CODE_OF_CONDUCT.md).
