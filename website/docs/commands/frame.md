---
id: frame
slug: frame
---

| Command | Default key binding | Alias |
| ------- | ------------------- | ----- |
| `frame [-h] [frame_id]` ||  |

Explore a particular frame with id `<frame_id>`. This is faster than `up` and `down`. See the [up docs](/docs/commands/up) for more information.

[up](/docs/commands/up), [down](/docs/commands/down), and [frame](/docs/commands/frame) commands respect [filter](/docs/guides/filter). All hidden frames are ignored, all C frames are ignored too.

**Examples:**

```
frame 0     # Jump to frame 0
frame 7     # Jump to frame 7
```
