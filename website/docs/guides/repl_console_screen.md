---
id: REPL console screen
---

import {LinkedImage} from '../../src/components/LinkedImage'

<LinkedImage link="/img/guides/repl-1.png" alt="REPL console screen"/>

Ruby Jard's REPL engine is powered by Pry, a runtime developer console with powerful introspection capabilities. There are plenty of things you can do with the REPL console:

- Ad-hoc code execution
- Inspect nested variable, support syntax highlight
- Source code browsing
- Document browsing
- Command shell integration
- Navigation around state
- Interfere and change current object state

To make use of all advaned features, please read [Pry documentation](https://github.com/pry/pry) for more information.

Some tips to work with Jard REPL console effeciently:
- Ruby Jard intercept the return value after evaluating your input, and perform decoration.
- Therefore, syntax highlighting doesn't work with `puts`. Instead of puts a complicated object into STDOUT, you just to type a variable, or method call, then press enter.

<LinkedImage link="/img/guides/repl-2.png" alt="Don't use puts"/>

- When you type too much, the terminal will be "scrolled" down. You can always scroll out, or use `list` to clear screen, and bring back the UI.
- If the output is too much, Ruby Jard triggers a [pager (less by default)](https://en.wikipedia.org/wiki/Less_\(Unix\)). You can navigate around the output with `hjkl` key bindings, and `q` to exit, back to the debugging interface.
