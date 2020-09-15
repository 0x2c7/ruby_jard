---
id: Installation
slug: /
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';
import {LinkedImage} from '../src/components/LinkedImage'
import {GithubButton} from '../src/components/GithubButton'

<img src="/img/logo/logo-full.png" width="400"/>
<br/><br/>

![Gem](https://img.shields.io/gem/v/ruby_jard?label=Latest%20version&style=for-the-badge) ![GitHub Workflow Status (branch)](https://img.shields.io/github/workflow/status/nguyenquangminh0711/ruby_jard/Rspec/master?label=Build&style=for-the-badge) ![GitHub stars](https://img.shields.io/github/stars/nguyenquangminh0711/ruby_jard?style=for-the-badge) [![From Vietnam with <3](https://raw.githubusercontent.com/webuild-community/badge/master/svg/love-modern.svg)](https://webuild.community)

**Note**: Ruby Jard is still under heavy development. Bugs and weird behaviors are expected. If you see one, please don't hesitate to [open an issue](https://github.com/nguyenquangminh0711/ruby_jard/issues). I'll try my best to fix.

## Install Ruby Jard

<Tabs
  defaultValue="bundler"
  values={[
    {label: 'Bundler', value: 'bundler'},
    {label: 'Ruby Gem', value: 'ruby_gem'}
  ]}>
  <TabItem value="bundler">

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

  </TabItem>

  <TabItem value="ruby_gem">

  If you want to install Ruby Jard independently from bundler:

  ```bash
  gem install ruby_jard
  ```

  If you want to install a specific version published on [Ruby gems](https://rubygems.org/gems/ruby_jard):

  ```bash
  gem install ruby_jard@0.2.3
  ```

  </TabItem>
</Tabs>

## Run your program with Ruby Jard

<LinkedImage link="/img/getting_started/how-to-use.gif" alt="How to run your program with Ruby Jard"/>

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

## Supported platform

- Ruby Jard supports official Ruby versions: 2.5.x, 2.6.x, 2.7.x, 2.8.x - 3.0.x (in ruby trunk).
- Truffle Ruby support is in the Roadmap.
- jRuby support is not promised yet, as byebug core is written in C.
- Ruby Jard is developed, and tested on Linux distros, and MacOS.
- Windows is not supported (yet).

## Dependencies

Ruby Jard depends on 3 dependencies:
- `byebug`, compatibility: '>= 9.1', '< 12.0'
- `pry`, compatibility: '~> 0.13.0'
- `tty-screen`, compatibility: '~> 0.8.1'

Ruby Jard is compatible with `pry` and `byebug`. They can be used along with each other without conflicts. However, as soon as Jard already started (via `jard` magic method call), this compatibility is not guaranteed.
