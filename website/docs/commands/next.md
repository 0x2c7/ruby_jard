---
id: next
slug: next
---

| Command | Default key binding | Alias |
| ------- | ------------------- | ----- |
| `next` | F8 | `n` |

Continue to the next line in the current frame. Bypasses any steppable method call or block in between unless they contain a dynamic breakpoint or a `jard` attachment command. If execution has reached the end of the current frame, next continues to the next line of the parent frame and so on.

**Examples:**

```
next     # Next instruction
next 3   # Next 3 next instructions
```
