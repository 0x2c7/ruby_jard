---
id: Screens
---

When Jard attaches at any line of code, the main tile-style UI shows up. By default, there are 5 areas on the UI that you'll be interested.

### Source screen

<img src="/img/screen-source.png" alt="Source screen" />

This screen shows the current line of code that your program is stopping, and surrounding related lines. The number of lines shown in this screen depends on your current terminal height, but never less than 5.

Ruby Jard supports any file extensions that your program runs into, especially `.rb`, `.erb`, `.haml` files. Other file types may encounter minor syntax highlighting issues.

Ruby Jard also supports inspecting gems and libraries, if you are interested.

### Backtrace screen

<img src="/img/screen-backtrace.png" alt="Screen backtrace"/>

This screen describes the current backtrace of the current thread your program is stopping. Each line of this screen describes the current Frame. What is frame and backtrace by the way? Let's step back a little bit at how Ruby executes your code. Internally, Ruby uses an interpreter to read and execute your code, line by line (technically, YARD instructions, but let's go with a simple version). When it meets a chunk of code that needs to open a new scope, like method calls or inline-block call, the interpreter creates a new structure to store the current context so that it can link to the next scope and go back later. This data structure is call Frame. The interpreter pushes frame into a stack, called backtrace (or stack trace, or call stack, whatever), and continues to execute your code. Each thread has a separate backtrace. To understand deeply, you may be interested in this wonderful slide: [Grow and Shrink - Dynamically Extending the Ruby VM Stack](https://www.slideshare.net/KeitaSugiyama1/grow-and-shrink-dynamically-extending-the-ruby-vm-stack).

Overall, the whole backtrace screen lets you know where you are stopping at, the trace of how your program is running. When combining with other tools and other screens, you will be surprised by how much information the bugger can help you when you encounter your bugs.

Each frame includes the following information:

- Frame ID: incremental, can be used to jump to an arbitrary frame with frame command.
- Current location label: a class name and method name of the method covers its frame. If there is a `[c]` prefix in front of a class name, it means that the method is provided by Ruby, implemented in C, and impossible to peek.
- Current physical location: exact file name and line number. If a frame is allocated in a gem, the physical location shows a gem name and version only. For example: `RSpec::Core::Hooks::HookCollections in run in rspec-core (3.9.2)`.

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
