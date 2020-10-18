---
id: Roadmap
slug: roadmap
---

Ruby Jard started its journey in July 2020. It's still young and under active development. This roadmap reflects the future and guides the development of Ruby Jard. I am working on Ruby Jard in my free time, so there won't be any commitments on the timeline. If you find a bug or want a change that helps your daily activities, please don't hesitate to [request a new feature](https://github.com/nguyenquangminh0711/ruby_jard/issues/new?assignees=&labels=enhancement&template=feature_request.md&title=).

### [Done] Version 0.1.0: Proof of concept

This version is a prototype to see whether my idea works or not in terms of technical feasibility and usability. Luckily everything works now, and I have received feedback from friends and peers.

### [Done] Version 0.2.0: UI completeness

The first version is just a series of ugly prints on stdout. It's frustrating to use as many things are broken, eg. wrong drawing, text overlapping, etc. This version fixes those issues and provides a foundation for more complicated drawing capabilities.

### [Done] Version 0.3.0: Complete the workflow

This version focuses on making Jard usable for the daily activities of the average developer. In other words, this version is a complete replacement for Byebug (sorry 🙏).

### Milestone: Dynamic Breakpoints

- Manage dynamic breakpoints
- Conditional breakpoints
- Standalone mode: `jard start -- bundle exec ruby abc.rb`
- Add temporary breakpoint support to existing commands. For example: `continue 35`, `continue SuperClass#method_a`, etc.
- `skip` command

### Milestone: Watch & Trace

- Watch an expression
- Pin variable
- Stop when a variable changes
- Stop when an exception is raised
- Trace code execution

### Milestone: Make the interfaces interactive

Ruby Jard now works well for all debugging use cases. But it has become bloated, hard to use, and maybe won't just "click" for the user. This version focuses on improving usability and stability, fixes bugs, and tweaks small details. After this version, Ruby Jard should be more pleasant to use.

- Navigate between panels.
- Collapsible and expandable variable inspection.
- Scrolling feature
- Mouse support
- Advanced command auto-completion

### Milestone: Ruby 3.0.0 is coming ...

Keeping up with Ruby 3.0.0's many new features is not easy. Some significant features I have in mind:
- Ruby type system
- Guild and real parallelism
- Ractor

### Milestone: Plugins & convenient tools

- Plugins to reinforce the most popular gems
  - Expand the support for Rails and friends
  - Expand variable inspection for RSpec

- Inline inspection (RubyMine-like)
- A fuzzy-style variable inspection tool
- Built-in hex viewer

### Milestone: Multi-threaded debugging

- Thread debugging modes
- Switch execution to another thread
- Start/Suspend a thread
- Defer output from background threads

### Milestone: Integration

Like it or not, not everyone uses vim or even the terminal. Even in the terminal, I just want to provide minimal layout customizations, as I don't want to rebuild Tmux. Therefore, in an effort to integrate with other powerful systems to extend use cases, adapting to different workflows and preferences is the focus of this version. I'm not sure about the final solution, but with my limited knowledge, the [Debugger Adapter Protocol](https://microsoft.github.io/debug-adapter-protocol/) looks promising.

- Prepare the infrastructure for DAP protocol.
- Separate and split the panels into possible isolated processes, connect them with DAP.
- Fully layout configurations and integration with Tmux.
- Integrate with Vim 8+/Neovim via Terminal mode.
- Integrate with Visual Studio Code via DAP.
- Integrate with Emacs via dap mode.
- Encrypted remote debugging

### Future Plans

If Ruby Jard has all these features and serves my interests, I won't have many other things in mind. The future is uncertain. Dreaming is good. Making dreams come true is hard, and time-consuming. I hope I can reach that future.
