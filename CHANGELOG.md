# Changelog

## [0.3.1]
This release fixes bunch of bugs, and performance issues reported by the users after beta launch. No new features are introduced.

- Pry and Byebug backward compatibility: [#39](https://github.com/nguyenquangminh0711/ruby_jard/issues/39), [#45](https://github.com/nguyenquangminh0711/ruby_jard/issues/45)
- Error with non-UTF8 encoding in the output: [#55](https://github.com/nguyenquangminh0711/ruby_jard/issues/55)
- Ctrl+D not working: [#34](https://github.com/nguyenquangminh0711/ruby_jard/issues/34)
- Errors if putting jard with `<%= jard %>` in ERB: [#35](https://github.com/nguyenquangminh0711/ruby_jard/issues/35)
- Handle standard stream redirections, and prevent Jard from attachment in invalid TTY device: [#38](https://github.com/nguyenquangminh0711/ruby_jard/issues/38), [#46](https://github.com/nguyenquangminh0711/ruby_jard/issues/46), [#53](https://github.com/nguyenquangminh0711/ruby_jard/issues/53)
- Bring back auto-resize when window size changes: [#40](https://github.com/nguyenquangminh0711/ruby_jard/issues/40)
- Improve performance after `exit` command: [#49](https://github.com/nguyenquangminh0711/ruby_jard/issues/49)
- Handle edge cases in Jard color decorator: [#54](https://github.com/nguyenquangminh0711/ruby_jard/issues/54)
- Escape all special characters and line feeds before printing stuff into the screen: [#57](https://github.com/nguyenquangminh0711/ruby_jard/issues/57)

## [0.3.0 - Beta 1]
- Filter feature
- New variable screen look and feel
- Improve website and documentation page.
- Improve color-scheme command
- Use Thread sequential label instead of Thread's object id
- Complete testing infrastructure.
- Fix multiple performance issues.

### Bug fixes
- Solve program output performance degrade ([#21](https://github.com/nguyenquangminh0711/ruby_jard/pull/21))

## [0.2.3 - Final Alpha]

### UX/UI
- Add `gruvbox`, `256-light`, `one-half-dark`, and `one-half-light` color scheme
- Add `jard output` command
- Add `jard hide` command
- Add `jard show` command
- Add `alias_to_debugger`, `enabled_screens` option
- Add responsive layouts to fit into different screen sizes
- Auto-adjust screens to utilize spaces on the screen
- Move variable screen to the right again (sorry :pray:)
- Small colorless friendly adjustment to variable and thread marks

### Bug fixes
- Jard doesn't work when place at the end of a method, or a block.
- Box title overflow
- Source screen doesn't work well with anonymous evaluation, or `ruby -e`
- Auto-completion with tab of pry (actually readline) is broken
- Could not exit when starting Jard inside irb
- Repl is broken if the keyboard repeat rate is too high.
- Fix broken frame command

### Internal & Refactoring
- Add tests for critical sections
- Use PTY to feed output from pry to actual STDOUT
- Use a custom pager to allow internal customization
- Improve performance of Jard when working with process with plenty of threads
- Handle key-binding spamming well
- Lazily load screen data
- Support byebug >= 9.1.0

## [0.2.2 - Alpha 4]

### UX/UI
- Add `wehereami` as an alias for `list` command
- Add `theme` command to switch theme at runtime
- Load configuration file when Jard starts

### Bug fixes
- Backward compatible issue: Array#filter is available in ruby 2.5.x and above.
- Fix Jard is bypassed when writting something to stdout while debugging (https://github.com/nguyenquangminh0711/ruby_jard/pull/5)

## [0.2.1 - Alpha 3] - Render mechanism and theme system
### UX/UI
- New color scheme: 256, as the default color scheme. It works well with all 256-color terminal emulators.
- New color scheme: deep-space. It's a 24-bit color scheme.
- UX change: swap positions of default panels:
    ```
      Source    | Backtrace
      Variables | Threads
    ```
- New narrow layout, which consists of source and variables only. Useful when running tests.
- Add aliases to common commands
### Bug fixes
- https://github.com/nguyenquangminh0711/ruby_jard/issues/2
- Fix display bug that some rows are out of screen if above rows have word wraps.
### Internal Refactoring
- New rendering mechanism, that supports data windowing, selection locating, and cursor.
- Improve compatibility, and add fallbacks in case io/console, or tput are not available.

## [0.2.0 - Alpha 2] - UI completeness

### UX/UI
- Improve box drawing.
- Isolate jard-related UI in an alternative termnial, just like Vim or Less.
- Restore printed information from STDOUT and STDERR after jard exits.
- Support keyboard shortcut.
- Support erb, haml highlighting.
- Increase contrast and enhance color scheme.
- Remove `finish` command.
- Add `frame` command.
- Add `step-out` command.
- Remove useless inline variables.
- Indicate types and inline variables in variable screen.

### Bug fixes
- Fix line number and loc mismatching if the current source viewport is at the start of the file.
- Multiple layout broken, overlapping text glitches.

### Internal & Refactoring
- Refactor screen's data flow.
- Standardize control flow.
- Replace `tty-cursor`, `tty-screen` by native Ruby alternative.
- Replace `tty-box` by home-growing solution.
- Remove text decorator.
- Implement color decorator
- Implement keybinding register and matching mechanism.
- Implement ReplProxy to wrap around Pry instance.
- Utility to debug and benchmark.

## [0.1.0 - Alpha 1] - Alpha initial version
**Release date**: July 1st 2020

- Default Terminal UI, in which the layout and display are responsive to support different screen size.
- Highlighted source code screen.
- Stacktrace visulization and navigation.
- Auto explore and display variables in the current context.
- Multi-thread exploration and debugging.
