# Fork release strategy

## Where things stand

- Upstream [`0x2c7/ruby_jard`](https://github.com/0x2c7/ruby_jard) was archived in 2023. The
  last release on RubyGems is `ruby_jard` **0.3.1**, which predates Ruby 3.4.
- This fork, [`fig/ruby_jard`](https://github.com/fig/ruby_jard), is a public GitHub fork. It
  supports Ruby 3.2 through 4.0 on byebug 12. The Ruby 3.4/4.0 work was done on the `upgrade`
  branch; see `CHANGELOG.md` under *Unreleased*.
- `lib/ruby_jard/version.rb` says `0.3.2.beta2`. That version was never published.
- The code is MIT licensed (`Copyright (c) 2020 Minh Nguyen`). Forking, renaming and
  republishing are allowed, provided the original copyright notice is kept.

## Phase 1: real-world use from git (current)

The goal is confidence from daily use before anything is published.

Users install straight from the fork:

```ruby
# Gemfile
gem 'ruby_jard', github: 'fig/ruby_jard'
```

Before pointing anyone at it:

- [ ] Open a PR from `upgrade` to `master` on the fork. CI runs only on pushes to `master` and
      on pull requests, so `upgrade` has not been through CI yet. Ruby 3.2 and 3.3 have only
      been partly tested locally.
- [ ] Merge once CI is green. Bundler installs the default branch (`master`) unless the user
      adds `branch:`.
- [ ] Tell users that Bundler locks git sources to a commit. They need
      `bundle update ruby_jard` to pick up fixes.

Areas to watch in real use. These are where the Ruby 3.4/4.0 changes landed, and the
integration suite covers them only partly:

- the pager (`less`) and `jard output`
- multi-threaded programs
- apps that customise Reline or IRB, or patch `Readline`
- stepping through C methods and core methods implemented in Ruby (`<internal:...>` frames)

Discoverability is limited in this phase. The fork appears in upstream's fork list, but
upstream is archived, so no new issues or README changes can point people at it. Word of
mouth and comments on existing upstream issues are the main channels.

## Phase 2: publishing a gem

### The naming decision

Everything else in this phase depends on the name.

| Option | How | For | Against |
|---|---|---|---|
| **A. Keep `ruby_jard`** | Ask the original author to add you as a RubyGems owner | Existing users upgrade with `bundle update`; no rename churn | Needs the author's reply; they may not respond |
| **B. New gem name** | Publish under a fresh name (check it's free on rubygems.org) | Fully under your control; can happen at any time | Existing users must edit their Gemfile; the old gem stays in search results |

Recommendation: try A first with a short, polite request. Fall back to B if there's no answer
within a few weeks.

If you choose B, keep `lib/ruby_jard/` and `require 'ruby_jard'` so the new gem replaces the
old one directly. The two gems then can't be installed in the same bundle, which is
acceptable and arguably desirable. Say so in the README.

### Pre-publish checklist

- [ ] **Gemspec metadata**: add yourself to `authors`/`email`. Point `homepage`,
      `source_code_uri` and `changelog_uri` at the fork; `changelog_uri` currently points at
      the repo root rather than the changelog. Consider `metadata['rubygems_mfa_required'] = 'true'`.
- [ ] **LICENSE**: add your copyright line below the original; keep the original.
- [ ] **README**: a short "maintained fork" notice at the top, supported Rubies, a link to
      the original project, and the byebug dependency caveat (see
      [debug-gem-port.md](debug-gem-port.md)). Replace links to the original website and
      issue tracker.
- [ ] **`website/`**: this Docusaurus site has many stale dependencies (roughly 20 open
      Dependabot alerts upstream). Either delete it and let the README carry the docs, or
      update and host it. Don't publish it as-is.
- [ ] **Version**: suggest `0.4.0` for the first fork release (new Ruby support and new
      runtime dependencies). Move the *Unreleased* changelog entries under it.
- [ ] **GitHub**: consider asking GitHub Support to detach the fork. Standalone repositories
      rank better in search and aren't grouped under an archived parent.
- [ ] **CI green** on the supported matrix (3.2, 3.3, 3.4, 4.0; Ubuntu and macOS). Check the
      weekly *Ruby head* workflow too: it is not a release gate, but it shows what the next
      Ruby will break.

## Ongoing policy (proposal)

- **Supported Rubies**: the CI matrix is the support statement. Drop a Ruby version only in
  a minor or major release, and say so in the changelog.
- **Dependencies**: runtime dependencies must work on every supported Ruby with a single
  gemspec, because a published gemspec's dependencies are fixed at build time, not install
  time. Version-specific behaviour belongs in code (`RUBY_VERSION` checks).
- **Test Gemfiles**: one Gemfile currently resolves on every supported Ruby. If a test
  dependency ever drops an older Ruby, add a `gemfiles/` directory with per-Ruby Gemfiles
  and set `BUNDLE_GEMFILE` in the CI matrix. There's no need for that yet.
- **Integration fixtures**: when Ruby changes text it formats itself (backtraces,
  `inspect`), add `name.ruby-X.Y.expected` variants instead of editing the base fixture.
  `spec/helpers/integration_helper.rb` picks the right one.

## Open decisions

1. Option A or B for the gem name, and the new name if B.
2. Keep or drop `website/`.
3. Whether the published 0.4.x stays on byebug, or waits for the `debug` port. The
   recommendation is to publish on byebug and do the port as a later major version.
