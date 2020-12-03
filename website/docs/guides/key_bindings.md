---
id: Key bindings
slug: key-bindings
---

import {LinkedImage} from '../../src/components/LinkedImage'

| Key Binding | Meaning | Equivalent command |
| ----------- | ------- | ------------------ |
| F2 | Switch [filter](/docs/guides/filter) mode | [filter](/docs/commands/filter) |
| F5 | Refresh the interface | [list](/docs/commands/list) |
| F6 | Move to parent frame in the backtrace | [up](/docs/commands/up) |
| Shift F6 | Move to child frame in the backtrace | [down](/docs/commands/down) |
| F7 | Detect and step into a method call or block on the current line | [step](/docs/commands/step) |
| Shift F7 | Finish execution of the current frame and jump to the next line of the parent frame | [step-out](/docs/commands/step-out) |
| F8 | Move to the next line | [next](/docs/commands/next) |
| F9, Ctrl+D | Continue the execution of your program until exit, or stop at the next break point | [continue](/docs/commands/continue) |

You can always customize the key bindings set by putting a simple setting in the [configuration file](/docs/guides/configurations). The list of natively supported key binding is defined in [this file](https://github.com/nguyenquangminh0711/ruby_jard/blob/master/lib/ruby_jard/keys.rb).

```ruby
config.key_bindings = {
  RubyJard::Keys::CTRL_N        => 'jard filter switch',
  RubyJard::Keys::META_L        => 'list',
  RubyJard::Keys::CTRL_F1       => 'up',
  RubyJard::Keys::CTRL_SHIFT_F1 => 'down',
  RubyJard::Keys::META_D        => 'step',
  RubyJard::Keys::META_O        => 'step-out',
  RubyJard::Keys::CTRL_META_N   => 'next',
  RubyJard::Keys::META_F1       => 'continue',
  RubyJard::Keys::META_SHIFT_F1 => 'continue',
  RubyJard::Keys::CTRL_C        => 'interrupt'
}
```

Jard also supports non-traditional and machine-dependent key bindings. For example, to map the `Ctrl+Home` key combination to the `next` command, you first need to get the code sequences of this combination. Let's run the following ruby program inside your terminal, press `Ctrl+Home`, copy the output, then put it into the configuration file.

```ruby
require 'io/console'

STDOUT.raw!
begin
  loop do
    begin
      data = STDIN.read_nonblock(255)
      exit if data == "\u0003"
      print data.inspect
    rescue IO::WaitReadable; sleep 0.1; end
  end
ensure
  STDOUT.cooked!
end
```

<LinkedImage link="/img/guides/key-bindings.png" alt="Capture raw key sequences"/>

In my machine, the above program prints `"\e[1;5H"`. My configuration to map `Ctrl+Home` to `next` command looks like this:

```ruby
config.key_bindings = {
  "\e[1;5H" => 'next'
}
```

If the above program doesn't print any output, it means the key combination is conflicted or already handled by some programs in your environment. Please pick another one.
