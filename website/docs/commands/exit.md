---
id: exit
slug: exit
---

| Command | Default key binding | Alias |
| ------- | ------------------- | ----- |
| `exit` |||

Stop the execution of the program. Interally, when `jard` receives this command, it removes all debugging hooks, and triggers `::Kernel.exit`. Some long-running processes like `puma` or `sidekiq` may capture this event, treat it as an error, and recover to keep the processes running. In such cases, it's recommended to use [continue](/docs/commands/continue) instead.
