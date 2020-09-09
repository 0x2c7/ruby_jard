---
id: Configurations
---

Ruby Jard supports customization via pre-loaded configuration files. You can configure Jard both globally, and per-project.

- The global configuration file is located at `~/.jardrc`.
- The project configuration file is located at `.jardrc` in working directory when you start Ruby Jard. Per-project ones will override, and merge with global ones.

There are some supported configurations:

| Name                | Description                                                  | Default |
| ------------------- | ------------------------------------------------------------ | ------- |
| `color_scheme`      | Choose your favorite color scheme. The list of color schemes can be looke up in [Color schemes session](#color-schemes), or from `jard color-scheme -l` command in REPL. | `256`   |
| `alias_to_debugger` | Use `debugger` instead of `jard` when debugging. | `false`   |

This is a complete example of a configuration file:

```ruby
config.color_scheme = "deep-space"
config.alias_to_debugger = true
```
