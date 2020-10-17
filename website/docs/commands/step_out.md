---
id: step-out
slug: step-out
---
import {LinkedImage} from '../../src/components/LinkedImage'

| Command | Default key binding | Alias |
| ------- | ------------------- | ----- |
| `step-out` | Shift + F7 | `so` |

The opposite of step. This command is used to finish the execution of the current frame and jump to the next line of the parent frame. In other words, this command is equivalent to the sequence `up` and `next`. If the parent frame has already finished, Jard continues to the next line in that frame's parent and so on.

This command is useful when you lose interest in a frame and want to easily return to the parent. For example, you might have accidentally stepped into a longgggg loop or into library source code.

**Examples:**

```
step-out     # Step out once
step-out 3   # Step out 3 times
```

<LinkedImage link="/img/commands/step-out.gif" alt="Step out example"/>
