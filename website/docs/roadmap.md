---
id: Roadmap
slug: roadmap
---

Ruby Jard started its journey in July 2020. It's still young and under active development. This roadmap reflects the future, navigates the development of Ruby Jard. I am working on Ruby Jard in my free time. So, there won't be any commitments on the timeline. If you find something wrong or want something that helps your daily activities, please don't hesitate to [request a new feature](https://github.com/nguyenquangminh0711/ruby_jard/issues/new?assignees=&labels=enhancement&template=feature_request.md&title=).

### [Done] Version 0.1.0: Proof of concept

This version is a bootstrap to see whether my idea works or not, in terms of technical possibility and user usability. Luckily, everything works now, and I receive possible feedback from friends and peers.

### [Done] Version 0.2.0: UI completeness

The bootstrap version is just a series of ugly prints on stdout. It's frustrating as many things can be broken, wrong drawing, text overlapping, etc. This version is to fix those issues and provide a foundation for more complicated drawings.

### [Done] Version 0.3.0: Complete the workflow

This version focuses on making Jard usable for the daily activities of any developer. In other words, this version is to become a complete replacement for Byebug (sorry 🙏).

### Milestone: Dynamic Breakpoints

- Manage dynamic breakpoints
- Conditional breakpoints
- Standalone mode: `jard start -- bundle exec ruby abc.rb`
- Add temporary breakpoints support to existing commands. For example: `continue 35`, `continue SuperClass#method_a`, etc.
- `skip` command

### Milestone: Watch & Trace

- Watch an expression
- Pin variable
- Stop when a variable changes
- Stop when an exception is raised
- Trace code execution

### Milestone: Make the interfaces interactive

Ruby Jard now serves well for all debugging use case. But it becomes floated, hard to use, and maybe just not "click" for the user. This version focuses on improving usability, stability, bugs, tweak small details. So, after this version, Ruby Jard is just pleasant to use.

- Navigate between panels.
- Collapsible and expandable variable inspection.
- Scrolling feature
- Mouse support

### Milestone: Ruby 3.0.0 is coming ...

Keeping up with Ruby 3.0.0's tons of new features is not easy. Some significant features in mind:
- Ruby type system
- Guild and real parallelism
- Ractor

### Milestone: Plugins & convenient tools

- Plugins to reinforce the most popular gems
  - Expand the support for Rails and friends
  - Expand variable inspections for RSpec

- Inline inspection (RubyMine-like)
- A fuzzy-style variable inspection tool
- Built-in hex viewer

### Milestone: Multi-threaded debugging

- Thread debugging modes
- Switch execution to another thread
- Start/Suspend a thread
- Defer output from background threads

### Milestone: Integration

Accept or not, not everyone uses vim or even terminal. Even in the terminal, I just want to provide minimal layout customizations, as I don't want to rebuild Tmux. Therefore, integration with other powerful systems to extend use cases, adapt different workflow and preferences is the focus on this version. I'm not sure about the ultimate solution, but at my limited knowledge now, [Debugger Adapter Protocol](https://microsoft.github.io/debug-adapter-protocol/) looks promising.

- Prepare the infrastructure for DAP protocol.
- Separate and split the panels into possible isolated processes, connect them with DAP.
- Fully layout configurations and integration with Tmux.
- Integrate with Vim 8+/Neovim via Terminal mode.
- Integrate with Visual Studio Code via DAP.
- Integrate with Emacs via dap mode.
- Encrypted remote debugging

### Further future

As soon as it reaches all those features, and serves my interest well, I don't have many things in mind now. The future is uncertain. Dreaming is good. Making dreams come true is hard, and time-consuming. Hope I can reach that future.
