---
id: REPL console screen
slug: repl-console-screen
---

import {LinkedImage} from '../../src/components/LinkedImage'

<LinkedImage link="/img/guides/repl-1.png" alt="REPL console screen"/>

Ruby Jard's REPL engine is powered by Pry, a runtime developer console with powerful introspection capabilities. There are plenty of things you can do with the REPL console:

- Ad-hoc code execution
- Inspect nested variables (supports syntax highlighting)
- Source code browsing
- Document browsing
- Command shell integration
- Navigation around state
- Interfere with and change current object state

To make use of all advanced features, please read the [Pry documentation](https://github.com/pry/pry).

Some tips to work with the Jard REPL console effectively:
- Ruby Jard intercepts the return value after evaluating your input, and performs decoration.
- Therefore, syntax highlighting doesn't work with `puts`. Instead of printing a complicated object into STDOUT, just type a the name of a variable or method call, then press enter.

<LinkedImage link="/img/guides/repl-2.png" alt="Don't use puts"/>

- When you type a lot, the terminal will become "scrolled" down. You can always scroll out, or use `list` to clear screen, and bring back the UI.
- If there is too much output, Ruby Jard triggers a [pager (less by default)](https://en.wikipedia.org/wiki/Less_\(Unix\)). You can navigate around the pager with the usual `hjkl` key bindings. Press `q` to return to the debugging interface.
