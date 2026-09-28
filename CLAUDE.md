# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ruby Jard is a terminal-based debugger for Ruby that provides a rich UI wrapping around Byebug. It offers features like highlighted source code, stacktrace visualization, variable exploration, and multi-thread debugging.

## Development Commands

### Testing
- `bundle exec rspec` - Run all tests
- `bundle exec rspec spec/path/to/specific_spec.rb` - Run specific test file
- `bundle exec parallel_rspec spec/` - Run tests in parallel

### Code Quality
- `bundle exec rubocop` - Run linting
- `bundle exec rubocop -a` - Auto-fix linting issues

### Build & Install
- `bundle install` - Install dependencies
- `rake build` - Build the gem
- `rake install` - Install the gem locally
- `rake release` - Release the gem (maintainers only)

## Architecture Overview

### Core Components

**Session Management (`lib/ruby_jard/session.rb`)**
- Entry point for debugging sessions
- Manages the lifecycle of debugging contexts

**REPL System**
- `repl_manager.rb` - Manages REPL interactions
- `repl_processor.rb` - Processes commands and input
- `repl_interceptor.rb` - Intercepts and handles debugging flow
- `repl_state.rb` - Tracks REPL state

**Screen & Layout System**
- `screen_manager.rb` - Manages multiple debug screens
- `screen_renderer.rb` - Renders screen content
- `layout_*.rb` files - Different layout configurations (wide, narrow, tiny)
- `screens/` directory - Individual screen implementations (source, variables, backtrace, etc.)

**Inspection System** (`lib/ruby_jard/inspectors/`)
- Modular object inspection with specialized inspectors for different data types
- `base.rb` - Base inspector class
- Type-specific inspectors for arrays, hashes, objects, strings, etc.

**Command System** (`lib/ruby_jard/commands/`)
- Debugging commands like step, next, continue, frame navigation
- Each command is a separate class inheriting from `base_command.rb`

### Key Design Patterns

- **Configuration-driven**: Uses `config.rb` for user customization
- **Modular screens**: Each debug view is a separate screen class
- **Responsive layouts**: Multiple layout templates adapt to terminal size
- **Command pattern**: Debug commands are individual classes
- **Decorator pattern**: Used for colorizing and formatting output

### Integration Points

- **Byebug Integration**: Core debugging functionality via Byebug gem
- **Pry Integration**: REPL functionality via Pry gem
- **TTY Integration**: Terminal UI via tty-screen gem

### Development Notes

- The codebase uses frozen string literals throughout
- Main entry point is the `jard` method added to Kernel module
- Debugging state is managed through thread-local variables
- UI rendering is optimized for different terminal sizes and capabilities