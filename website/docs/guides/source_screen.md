---
id: Source screen
slug: source-screen
---

import {LinkedImage} from '../../src/components/LinkedImage'

<LinkedImage link="/img/guides/source-screen-1.png" alt="Source screen"/>

This screen shows the current line of code that your program has stopped at, including some surrounding lines. The number of lines shown on this screen depends on your current terminal height, but is never less than 5.

Ruby Jard supports any file type that your program might run into, especially `.rb`, `.erb`, `.haml` files. Other file types may encounter minor syntax highlighting issues.

Ruby Jard also supports jumping freely into application source code, gem source code, code evaluation, and even Ruby's standard library. It's impossible to inspect Ruby methods written in C though.

The secondary title at the top-left indicates the current file location.

<LinkedImage link="/img/guides/source-screen-2.png" alt="Debugging SecureRandom#uuid - a standard lib"/>
<LinkedImage link="/img/guides/source-screen-3.png" alt="Debugging Rails's ActiveRecord gem"/>
