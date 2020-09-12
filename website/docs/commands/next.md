---
id: next
slug: next
---

| Command | Default key binding | Alias |
| ------- | ------------------- | ----- |
| `next` | F8 | `n` |

Continue to the next line in the current frame, by pass any steppable method call or blocks in the mid way unless they contains dynamic breakpoint or any `jard` attachment command. If the current frame already reaches the end, it continues to the next line of upper frame and so on.

**Examples:**

```
next     # Next instruction
next 3   # Next 3 next instructions
```
