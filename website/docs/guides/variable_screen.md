---
id: Variable screen
slug: variable-screen
---

import {LinkedImage} from '../../src/components/LinkedImage'

<LinkedImage link="/img/guides/variable-screen-1.png" alt="Variable screen"/>

The variable screen lets you explore all the variables in the current display context. Each variable is described by:

- Variable name: underlining indicates a variable that appears on the current line.
- Size of variable: the size of collection-like variables. The current Jard version supports 3 types:
  - Hash: this field shows the number of keys
  - Array: this field shows the number of elements
  - String: this field shows the number of characters (fetched from the `String#size` method)
- Variable inspection. Jard implements a custom inspect method. The generated inspection string is optimized to be viewed within a particular area rather than the full output. This avoids filling up the area with all the output from a deeply nested object nobody can comprehend.

By default, Jard displays relevant variables only (i.e. variables present in the current file), and sorts by the following criteria:

- Current context (self)
- Local variables.
- Instance variables.
- Constants.
- Global variables.

### Rails Plugin

Rails is special both in terms of its popularity and how it's implemented. Ruby Jard includes some special code for Rails.

<LinkedImage link="/img/guides/variable-screen-2.png" alt="Variable screen"/>

**Note**: Jard only displays active record relations if all the records are loaded into memory. Otherwise, it displays the underlying SQL query instead. In above example, `@events_2` and `@events_3` are equivalent except that `@events_2` has already fetched the records from database.
