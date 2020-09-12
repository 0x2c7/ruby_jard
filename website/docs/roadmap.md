---
id: Roadmap
slug: roadmap
---

### [Done] Version 0.1.0: Proof of concept

This version is a bootstrap to see whether my idea works or not, in term of technical possibility and user usability. Luckily, everything works now, and I receive possible feedback from friends and peers.

### [Done] Version 0.2.0: UI completeness

The bootstrap version is just a series of ugly prints on stdout. It's frustrated as many things can be broken, wrong drawing, text overlapping, etc. This version is to fix those issues, and provide a foundation for more complicated drawing.

### Version 0.3.0: Complete the workflow

This version focuses on making Jard usable for daily activities of any developer. In other words, this version is to become a complete replacement for Byebug (sorry :pray:).

- Manage program's STDOUT.
- Fulfill options for existing commands.
- Add more commands to control workflow.
- etc.

### Version 0.4.0: User satisfaction

Ruby Jard now serves well for all debugging use case. But it becomes floated, hard to use, and maybe just not "click" for the user. This version focuses on improve userability, stability, bugs, tweak small details. So that, after this version, Ruby Jard is just pleasant to use.

- Support different screen sizes.
- Minimal layout configuration.
- Allow customizations (keyboard shortcut for example).
- Rebuild variable inspection to optimize for each data type, especially nested complicated structure.
- Collapsible and expandale variable inspection.
- Windows, viewport, scrolling, etc.
- Navigate between panels.
- Build a buffer system to reduce interaction with STDOUT, and eventually improve drawing latency.

- Dynamic breakpoints.
- Watch expressions.
- Pin variables.
- Post moterm.
- Trace variable changes.

### Version 0.5.0: Integration

Accept or not, not everyone uses vim, or even terminal. Even in the terminal, I just want to provide minimal layout customizations, as I don't want to rebuild Tmux. Therefore, integration with other powerful systems to extend use cases, adapt different work flow and preferences is the focus on this version. I'm not sure about the ultimate solution, but at my limited knowledge now, [Debugger Adapter Protocol](https://microsoft.github.io/debug-adapter-protocol/) looks promising.

- Prepare the infrastructure for DAP protocol.
- Separate and split the panels into possible isolated processes, connect them together with DAP.
- Fully layout configurations and integrate with Tmux.
- Integrate with Vim 8+/Neovim via Terminal mode.
- Integrate with Visual Studio Code via DAP.
- Integrate with Emacs via dap mode.
- Encrypted remote debugging.

### Further future

I won't stop until 0.5.0 version, even Jard doesn't have any users. However, as soon as it reaches 0.5.0, and serves my interest well, I don't have much things in mind now. The future is uncertain. Dreaming is good. Making dreams come true is hard, and time-consuming. Hope I can reach that future.
