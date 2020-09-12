---
id: Filter
slug: filter
---

You can either change the filter mode on the fly with [filter comamnd](/docs/commands/filter), or use a global/per-project [configuration file](/docs/guides/configurations). Ruby Jard has a strong filtering system. This system consists of a filter mode, included list, and excluded list. Filter mode is how Ruby Jard reacts to control flow commands. There are 4 filter modes:

- Application (`application`) - default mode. This mode filters out all backtrace in gems, standard libs, and some weird places you won't be interested in. All control flow commands ([step](/docs/commands/step), [next](/docs/commands/next)) bypass gems/standard libs, and stop at the next point in the application only.

- Gems (`gems`). This mode allows you to step into the gems layer, plus the application layer, of course. This mode is useful when you need to debug a problem inside a gem, called from your application. All backtrace in the application and gems are visible. All control flow commands bypass the standard libs only.

- Everything (`everything`). This mode enables you step into any places, including standard libs. This is the most powerful (and noise!). One note here, Ruby Jard can't step into any method implemented in C.

- Source Tree (`source_tree`). This mode is the most restrictive. It only allows you to jump into a file belongs to the source tree started at current working dir. This mode is useful if you cares a sub-folder of a big source code only; or in a mono-repo (hi Stripe).

Filter modes collaborate with included list/excluded list. Included list/excluded list follows [Ruby glob pattern](https://ruby-doc.org/core-2.6.3/Dir.html). It works with gem name, and path.

### Filter in action
[![Filter in action](https://asciinema.org/a/359326.svg)](https://asciinema.org/a/359326)

### Examples

| Filter mode | Included list | Excluded list | Meanings |
| ----------- | ------------- | ------------- | -------- |
| `application` | `i18n` | | Brake at application codes, and everything in `i18n` gem. |
| `application` | `httparty`, `faraday` | `lib/dsl/*`, `lib/shared/*` | Brake at application codes, httparty and faraday gems, ignore DSL files and shared libraries |
| `application` | `aws-*`| `sidekiq` | Brake at application codes and all AWS gems, but don't care about sidekiq framework |
| `application` | `ipaddr`, `puma`, `uri`, `resolv` | `lib/**/*.erb` | Ah. You are a low-level ruby developer right? `puma` is a web server gem; `ipaddr`, `uri`, and `resolv` are standard lib. All erb files are ignored |
| `gems` |  | `active*`, `action*` | Who ares about rails internal? |
