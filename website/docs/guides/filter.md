---
id: Filter
slug: filter
---

You can either change the filter mode on-the-fly with the [filter comamnd](/docs/commands/filter) or use a global/per-project [configuration file](/docs/guides/configurations). Ruby Jard features a powerful filtering system. This system consists of a filter mode, include list, and exclude list. The filter mode defines how Ruby Jard reacts to control flow commands. There are 4 filter modes:

- Application (`application`) - default mode. This mode filters out all backtraces in gems, the standard library, and some weird places you won't be interested in. All control flow commands ([step](/docs/commands/step), [next](/docs/commands/next)) bypass gems and the standard lib and stop at the next point in the application only.

- Gems (`gems`). This mode allows you to step into gem code _and_ the application layer. This mode is useful when you need to debug a problem inside a gem called from your application. All backtrace information from the application and gems is visible. All control flow commands bypass the standard library only.

- Everything (`everything`). This mode enables you to step anywhere, including the standard library. This is the most powerful (and noisiest!). One note here: Ruby Jard can't step into any method implemented in C.

- Source Tree (`source_tree`). This mode is the most restrictive. It only allows you to jump into a file belonging to the source tree rooted in the current working directory. This mode is useful if you only care about the code in a particular subfolder of a big project or mono-repo (hi Stripe).

Filter modes work with the include/exclude lists, which make use of [Ruby glob patterns](https://ruby-doc.org/core-2.6.3/Dir.html). The lists are comprised of gem name and path.

### Filter in action
[![Filter in action](https://asciinema.org/a/359326.svg)](https://asciinema.org/a/359326)

### Examples

| Filter mode | Included list | Excluded list | Meanings |
| ----------- | ------------- | ------------- | -------- |
| `application` | `i18n` | | Break in application code and anything in the `i18n` gem. |
| `application` | `httparty`, `faraday` | `lib/dsl/*`, `lib/shared/*` | Break in application code and the httparty and faraday gems; ignore DSL files and shared libraries |
| `application` | `aws-*`| `sidekiq` | Break in application code and all AWS gems, but ignore the sidekiq framework |
| `application` | `ipaddr`, `puma`, `uri`, `resolv` | `lib/**/*.erb` | Ah. You are a low-level ruby developer right? `puma` is a web server gem; `ipaddr`, `uri`, and `resolv` are standard lib. All erb files are ignored |
| `gems` |  | `active*`, `action*` | Who cares about rails internals? |
