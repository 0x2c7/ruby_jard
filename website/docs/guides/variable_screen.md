---
id: Variable screen
slug: variable-screen
---

import {LinkedImage} from '../../src/components/LinkedImage'

<LinkedImage link="/img/guides/variable-screen-1.png" alt="Variable screen"/>

The variable screen lets you explore all the variables in the current display context. Each variable is described by:

- Variable name: underlining implies a variable that appears in the current line.
- Size of variable: the size of collection-like variables. Current Jard version supports 3 types:
  - Hash: this field shows the number of keys
  - Array: this field shows the number of items
  - String: this field shows the number of character (fetched from`String#size` method)
- Variable inspection. Jard implements a custom inspecting method. The generated inspection is optimized for overview within a area, instead of a full page of string from a deeply nested object nobody can comprehend.

By default, Jard displays relevant variables (which means variables used in the current file) only, and sorts by the following criterias:

- Current context (self)
- Local variables.
- Instance variables.
- Constants.
- Global variables.

### Rails Plugin

Rails is special, in term of both popularity and how it is implemented. Ruby Jard has some special treatments for Rails.

<LinkedImage link="/img/guides/variable-screen-2.png" alt="Variable screen"/>

**Note**: Jard only display active record relation, if all the records are loaded into memory. Otherwise, it displays underlying SQL query instead. In above example, `@events_2` and `@events_3` are equivalent, except `@events_2` already materalizes the records from DB.
