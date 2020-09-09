---
id: Screens
---

When Jard attaches at any line of code, the main tile-style UI shows up. By default, there are 5 areas on the UI that you'll be interested.


### Thread screen

<img src="/img/screen-threads.png" alt="Screen threads" />

Show all the threads running at the moment. This screen is useful when you are working with a complicated multi-threaded environment like web server, or background jobs.

### Repl screen

<img src="/img/screen-repl.png" alt="Screen repl" />

An interactive Repl for you to interact with your program, inspect values, update values, or control the debug flow as you want. The heart of Jard's repl is [Pry](https://github.com/pry/pry), a masterpiece gem. When you type a command, Jard parses, and does corresponding actions if what you type matches supported command. Otherwise, they are evaluated as Ruby code.
