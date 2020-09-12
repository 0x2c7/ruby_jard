---
id: step-out
slug: step-out
---

import {LinkedImage} from '../../src/components/LinkedImage'

| Command | Default key binding | Alias |
| ------- | ------------------- | ----- |
| `step-out` | Shift + F7 | `so` |

The opposite of step. This command is used to finish the execution of current frame, and jump to the next line of upper frame. In other words, this command is equivalent to the sequence `up` and `next`. If the neighbor frame already finishes, it continues with even higher frame.

This command is useful when you loose your interest in frame, and want to quickly go up again. One example is that you accidentally step into a longgggg loop with nothing useful. Another example is that you step into the library source code and don't really care what it does underlying.

**Examples:**

```
step-out     # Step out once
step-out 3   # Step out 3 times
```


<LinkedImage link="/img/commands/step-out.gif" alt="Step out example"/>
