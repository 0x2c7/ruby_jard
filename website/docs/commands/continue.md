---
id: continue
slug: continue
---

| Command | Default key binding | Alias |
| ------- | ------------------- | ----- |
| `continue` | F9 | `c` |

Continue the execution of your program to the end, or stop at the first dynamic break point or `jard` attachment command. One common confusion is that long-running ruby processes, such as web server or background jobs, won't stop, and may be used to debug the next request without restarting. If you want to end everything and just exit the process, let's use `exit`.
