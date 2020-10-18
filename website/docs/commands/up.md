---
id: up
slug: up
---
import {LinkedImage} from '../../src/components/LinkedImage'

| Command | Default key binding | Alias |
| ------- | ------------------- | ----- |
| `up` | F6 |  |

Explore the parent frame. When you use this command, all associated display screens will be updated accordingly, but your program's current position is still the latest frame. This command is mostly used to explore and introspect the stack, input parameters, or how your program has stopped at the current position. When using this command, take a look at the Variable and Source panels to see the variables defined in the current frame.

You can combine `up` with `next` or `step` to perform powerful execution redirection at from the current frame. Let's look at an example. You are debugging a chain of 10 rack middlewares and you go deep into the ninth middleware. You find something and want to go back to the fifth middleware. It's pretty tedious and frustrating to use `next` or `step-out` and hope you eventually end up in the right place. Consider using `up` a few times (or `frame`, described below) to go to the desired frame, then use `next`. Tada! It's magical, like teleporting yourself to the right position.

[up](/docs/commands/up), [down](/docs/commands/down), and [frame](/docs/commands/frame) commands respect [filter](/docs/guides/filter). All hidden frames and C frames are ignored.

**Examples:**

```
up     # Move to upper frame
up 3   # Move to upper 3 frames
```

<LinkedImage link="/img/commands/up.gif" alt="Up example"/>
