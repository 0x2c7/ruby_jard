---
id: Color schemes
---

Ruby Jard bundles 6 built-in schemes, 4 dark ones, and 2 light ones. You can use [color scheme commands](/docs/commands/color_scheme) to up the flight, or define in [configuration file](/docs/guides/configurations).

### 256
Default scheme, 256 basic colors, supported by all terminals

![256 Color scheme](/img/color_schemes/256.png)

### 256-light
Light 256 basic colors

![256-light Color scheme](/img/color_schemes/256-light.png)

### Deep space

![Deep space color scheme](/img/color_schemes/deep-space.png)

### Gruvbox

![Gruvbox color scheme](/img/color_schemes/gruvbox.png)

### One half dark

![One half dark color scheme](/img/color_schemes/one-half-dark.png)

### One half light

![One half light color scheme](/img/color_schemes/one-half-light.png)

### Your custom theme

Add those lines into your [configuration file](/docs/guides/configurations). Ruby Jard supports two types of colors: 24-bit color or [ANSI 8-bit color](https://en.wikipedia.org/wiki/ANSI_escape_code).

```ruby
class MyColorScheme < ColorScheme
  GRAY1      = '#1b202a'
  GRAY2      = '#232936'
  GRAY3      = '#323c4d'
  GRAY4      = '#51617d'
  GRAY5      = '#9aa7bd'
  WHITE      = '#fff'
  RED        = '#b15e7c'
  GREEN      = '#80b57b'
  YELLOW     = '#e8cb6b'
  BLUE       = '#78b5ff'
  PURPLE     = '#b08aed'
  CYAN       = '#56adb7'
  ORANGE     = '#f28d5e'
  PINK       = '#c47ebd'

  BACKGROUND = GRAY1
  STYLES = {
    background:        [WHITE, BACKGROUND],
    border:            [GRAY3, BACKGROUND],
    title:             [GRAY2, BLUE],
    title_secondary:   [WHITE, GRAY3],
    title_background:  [GRAY2, GRAY2],
    text_primary:      [GRAY5, BACKGROUND],
    text_dim:          [GRAY4, BACKGROUND],
    text_highlighted:  [BLUE, BACKGROUND],
    text_special:      [ORANGE, BACKGROUND],
    text_selected:     [GREEN, BACKGROUND],
    keyword:           [BLUE, BACKGROUND],
    method:            [YELLOW, BACKGROUND],
    comment:           [GRAY4, BACKGROUND],
    literal:           [RED, BACKGROUND],
    string:            [GREEN, BACKGROUND],
    local_variable:    [PURPLE, BACKGROUND],
    instance_variable: [PURPLE, BACKGROUND],
    constant:          [BLUE, BACKGROUND],
    normal_token:      [GRAY5, BACKGROUND],
    object:            [CYAN, BACKGROUND]
  }.freeze
end

RubyJard::ColorSchemes.add_color_scheme('my-color', MyColorScheme)
config.color_scheme = "my-color"
```
