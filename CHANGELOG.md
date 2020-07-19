# Changelog

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
