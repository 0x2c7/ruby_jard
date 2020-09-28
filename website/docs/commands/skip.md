---
id: skip
slug: skip
---
import {LinkedImage} from '../../src/components/LinkedImage'

| Command | Default key binding | Alias |
| ------- | ------------------- | ----- |
| `skip [-a -all]` | | |

Continue the execution of your program to the end, and skip one, or more next breakpoints it meets. This command is useful when you puts `jard` command in an iteration or a nested method calls.

**Note:**
Ruby Jard resets skipping list in next attachment, or when your program exits. If you are running a web server, or background jobs that prevent your program from stopping, and you already skip all breakpoints, your program may not stop, and requires a restart to attach again.

**Examples:**

```
skip      # Continue and skip the first breakpoint
```
<LinkedImage link="/img/commands/skip.gif" alt="Skip example"/>

```
skip 2    # Continue and skip the first 2 breakpoints it meets
```
<LinkedImage link="/img/commands/skip-2.gif" alt="Multiple skip example"/>

```
skip -all # Continue and skip all breakpoints
```
<LinkedImage link="/img/commands/skip-all.gif" alt="Skip all example"/>
