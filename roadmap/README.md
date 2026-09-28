# Roadmap

Planning notes for this fork of [ruby_jard](https://github.com/0x2c7/ruby_jard), which
upstream archived in 2023. These are working documents, not commitments. Update them as
decisions are made.

| Document | Covers |
|---|---|
| [fork-release-strategy.md](fork-release-strategy.md) | How the fork gets to users: git-sourced use now, then a published gem, and the naming decision that release depends on |
| [debug-gem-port.md](debug-gem-port.md) | Moving Jard's backend from byebug to Ruby's official `debug` gem |

This directory is excluded from the packaged gem (see `spec.files` in `ruby_jard.gemspec`).
