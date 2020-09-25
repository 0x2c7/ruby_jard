---
id: filter
slug: filter
---
import {LinkedImage} from '../../src/components/LinkedImage'

| Command | Default key binding | Alias |
| ------- | ------------------- | ----- |
| `jard filter`  | | |
| `jard filter [everything, gems, application, source_tree]`  | | |
| `jard filter [include, exclude] pattern` | | |
| `jard filter clear` | | |

Ruby Jard has a strong filtering system. This system consists of a filter mode, included list, and excluded list. Filter mode is how Ruby Jard reacts to control flow commands. See [filter](/docs/guides/filter) for more information.

**Examples:**

```
jard filter # Show filter status
```

<LinkedImage link="/img/commands/filter.png" alt="Filter example"/>

```
jard filter application # Switch to application mode
jard filter gems # Switch to gems mode
jard filter everything # Switch to everything mode
jard filter source_tree # Switch to source tree mode
```

```
jard filter include sidekiq # Include sidekiq pattern
jard filter include aws-*
jard filter include aws-* active* action* # Multiple patterns separated by <space>
jard filter include lib/**/*.erb
jard filter include ~/home/lib/**/*.rb
```

```
jard filter exclude sidekiq # exclude sidekiq pattern
jard filter exclude aws-*
jard filter exclude aws-* active* action* # Multiple patterns separated by <space>
jard filter exclude lib/**/*.erb
jard filter exclude ~/home/lib/**/*.rb
```

```
jard filter clear # Clear filter
```
