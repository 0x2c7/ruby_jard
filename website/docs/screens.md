---
id: Screens
---

When Jard attaches at any line of code, the main tile-style UI shows up. By default, there are 5 areas on the UI that you'll be interested.

### Variable screen

<img src="/img/screen-variables.png" alt="Variables screen"/>

The variable screen lets you explore all the local variables, instance variables, and constants in the current display context. Each variable is described by:

- Inline indicator: the beginning dot (`•`) implies a variable that appears in the current line.
- Variable type: allow you to know the type of a variable at a single glance. Only built-in types, such as `int`, `flt`, `hash`, `bool`, `rng`, are supported. Instances of any classes will be noted as `var`.
- Size of variable: the size of collection-like variables. Current Jard version supports 3 types:
  - Hash: this field shows the number of keys
  - Array: this field shows the number of items
  - String: this field shows the number of character (fetched from`String#size` method)
- Variable inspection: the content of the variable. The current Jard version generates this field by calling `#inspect`. **Known issue**: this accidentally triggers materializing method of objects, such as `ActiveRecord::Relation`. Future Jard version gonna fix this by a new safe generator.

This screen interacts well with backtrace screen and backtrace-exploring commands such as (`up`, `down`, `frame`, etc.) to inspect relative variables at each frame layer in the program. A common use case is to recall the parameter values you forgot when digging too deep into a method call.

By default, the variables are sorted by the following criteria:

- Pinned variables (coming soon)
- Current context (self)
- Local variables
- Instance variables
- Constants
- Global variables (coming soon)

### Thread screen

<img src="/img/screen-threads.png" alt="Screen threads" />

Show all the threads running at the moment. This screen is useful when you are working with a complicated multi-threaded environment like web server, or background jobs.

### Repl screen

<img src="/img/screen-repl.png" alt="Screen repl" />

An interactive Repl for you to interact with your program, inspect values, update values, or control the debug flow as you want. The heart of Jard's repl is [Pry](https://github.com/pry/pry), a masterpiece gem. When you type a command, Jard parses, and does corresponding actions if what you type matches supported command. Otherwise, they are evaluated as Ruby code.
