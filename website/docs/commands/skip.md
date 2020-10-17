---
id: skip
slug: skip
---
import {LinkedImage} from '../../src/components/LinkedImage'

| Command | Default key binding | Alias |
| ------- | ------------------- | ----- |
| `skip [-a -all]` | | |

Continue the execution of your program to the end, and skip one or more next breakpoints along the way. This command is useful when you put the `jard` command in an iteration or a nested method call.

**Note:**
Ruby Jard resets the skip list in the next attachment or when your program exits. If you are running a web server or a background job that prevents your program from stopping (and you have already skipped all breakpoints), your program may not stop and may require a restart to attach again.

**Examples:**

```
skip      # Continue and skip the first breakpoint
```
<LinkedImage link="/img/commands/skip.gif" alt="Skip example"/>

```
skip 2    # Continue and skip the first 2 breakpoints
```
<LinkedImage link="/img/commands/skip-2.gif" alt="Multiple skip example"/>

```
skip -a    # Continue and skip all breakpoints
skip --all # Continue and skip all breakpoints
```
<LinkedImage link="/img/commands/skip-all.gif" alt="Skip all example"/>
