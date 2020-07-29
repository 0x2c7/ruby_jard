# Changelog

## [0.2.2 - Alpha 3] - Unreleased

### UX/UI
- Add `wehereami` as an alias for `list` command

### Bug fixes
- Backward compatible issue: Array#filter is available in ruby 2.5.x and above.


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

## [0.1.0 - Alpha] - Alpha initial version
**Release date**: July 1st 2020

- Default Terminal UI, in which the layout and display are responsive to support different screen size.
- Highlighted source code screen.
- Stacktrace visulization and navigation.
- Auto explore and display variables in the current context.
- Multi-thread exploration and debugging.
