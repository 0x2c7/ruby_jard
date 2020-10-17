---
id: step
slug: step
---

| Command | Default key binding | Alias |
| ------- | ------------------- | ----- |
| `step` | F7 | `s` |

Detect and step into a method call or block on the current line. If there isn't anything to step into, the program will continue to the next line. If there are multiple methods on the same line, Jard hornors Ruby's execution order.

**Examples:**

```
step     # Step once
step 3   # Step 3 times
```
