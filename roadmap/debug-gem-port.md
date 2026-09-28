# Porting Jard from byebug to `debug`

## Why

Jard is built on byebug. Byebug 12 compiles and works on Ruby 4.0, but it's a third-party C
extension, and Ruby's official debugger is now [`debug`](https://github.com/ruby/debug). It
is a bundled gem maintained by Ruby core, and it gains support for new Ruby versions first.
If byebug falls behind a Ruby release, Jard stops working. Moving to `debug` removes that
risk and replaces some byebug workarounds with richer frame data.

This is not urgent while byebug keeps up. Treat it as the next major version.

## What carries over

Line counts are non-blank, non-comment lines in `lib/ruby_jard` at the time of writing
(~5,500 in total).

| Area | Lines | Coupling | In the port |
|---|---|---|---|
| Rendering and layout engine (`layout*`, `screen*`, `row*`, `span`, `column`, `box_drawer`) | ~1,140 | None | Reuse |
| Screens (`screens/`) | ~580 | Read from `Session` and `Frame` | Reuse via the backend interface |
| Inspectors, decorators | ~970 | None | Reuse |
| Colour schemes | ~310 | None | Reuse |
| Config, path classifier/filter, reflection | ~400 | None | Reuse; filtering may partly move to `debug`'s `skip_path` |
| **Debugger glue** (`session`, `frame`, `thread_info`, `repl_processor`) | ~420 | **byebug** | Rewrite behind an adapter |
| **REPL layer** (`pry_proxy`, `repl_*`, `pager`, `key_binding*`, `console`, `control_flow`) | ~1,220 | **Pry** | Largely rewrite on Reline |
| **Commands** (`commands/`) | ~620 | **Pry** command classes | Rewrite as `debug` command strings and Jard-local commands |

About 60% carries over. The tmux screen-capture integration suite (`spec/integration`) is
also reusable. If the screens render the same, those fixtures become the port's acceptance
tests.

## How `debug` can host a custom front-end

References are to `debug` 1.11.1. Verify them against the version you pin, because none of
this is public API.

- **The UI object is the extension point.** A UI subclasses `DEBUGGER__::UI_Base`
  (`session.rb`); `UI_LocalConsole` in `local.rb` is the reference implementation. There's no
  `suspend(tp, thread_client)` hook to override, which is where the earlier attempt went
  wrong (see below).
- **Suspension flow** (`Session#process_event`, the `when :suspend` branch): the session
  calls `@ui.event(:suspend_bp | :suspend_trap | :suspended, …, tc_id)`, then enters
  `wait_command_loop`. That loop repeatedly calls `@ui.readline(prompt)` and passes each
  line to `process_command`.
- **Commands are strings.** `readline` returns `step`, `next`, `finish`, `up`, `down`,
  `frame N`, `c`, `info`, and so on. A line that isn't a command is evaluated as Ruby on the
  suspended thread. Jard's key bindings (F7/F8/F9…) therefore become "return this command
  string from `readline`".
- **Frame data**: `DEBUGGER__::FrameInfo` (`frame_info.rb`) carries `location`, `self`,
  `binding`, `class`, `iseq`, return values and raised exceptions. That's richer than byebug.
  The native-frame workaround in `RubyJard::Frame` probably becomes unnecessary.
- **Useful config** (`config.rb`): `skip_path` and `skip_nosrc` (stepping filters),
  `irb_console` (IRB as the console), and `no_sigint_hook`.

### Proposed mapping

| Jard behaviour | `debug` mechanism |
|---|---|
| Redraw screens when execution stops | `UI#event(:suspended/:suspend_bp/...)` |
| Prompt and key bindings | `UI#readline` runs Jard's input loop and returns a command string |
| `step`/`next`/`step-out`/`continue` | `step` / `next` / `finish` / `c` |
| `up`/`down`/`frame N` | `up` / `down` / `frame N` |
| Filtering app/gems/stdlib | `skip_path` where it fits; Jard's classifier decides what to skip |
| Evaluating Ruby | Non-command lines are evaluated by `debug` on the suspended thread |
| `jard` entry point | `binding.break` / `DEBUGGER__.start` + a breakpoint at the caller |

## Hard parts and risks

1. **Internal API.** `UI_Base`, `ThreadClient`, `FrameInfo` and the event names aren't
   public. The editor integrations (DAP/CDP) use them, but a `debug` release could still
   change them. Pin `debug` tightly (`~> 1.11.0`), and add a CI job against `debug`'s
   `master` to get early warning.
2. **Threading.** The session runs on its own thread. The screens need frame data belonging
   to the suspended thread. Reading `ThreadClient` state directly across threads works while
   that thread is blocked, but isn't guaranteed. The robust route is custom requests to the
   thread client, as `server_dap.rb` does, which is more internal API.
3. **Losing Pry.** Evaluation happens on the suspended thread through `debug`, so Pry can't
   simply wrap it. The Pry proxy, interceptor and Pry-based commands (~1,800 lines) get
   rewritten on Reline. Users lose Pry commands (`ls`, `cd`, `show-source`) unless they're
   rebuilt or `irb_console` is used. Decide early which of these matters.
4. **Semantic differences.** `debug` stops all threads when suspended, and its
   step/finish behaviour isn't identical to byebug's. Some integration fixtures will need
   re-recording, with judgement about which behaviour is correct.
5. **Signals and terminal state.** `debug` installs its own SIGINT handling and manages the
   console. Jard's raw/cooked switching, its PTY output bridge and the pager must cooperate
   with it. Recent fixes (`IO#wait_readable`, pager on the real TTY) show this layer is
   fragile.

## Lessons from the first attempt

An earlier attempt (commit `75fe366` "Support Rubby 4.0"; its branch has been deleted)
swapped byebug for `debug` in one step. It was written against APIs that don't exist:
`UI_Base#suspend(tp, thread_client)` and `ThreadClient#step_into`/`#step_over`. It was never
run. Takeaways:

- Read `debug`'s source for every hook you rely on, and prove each one with a spike before
  building on it.
- Don't replace the backend in one step. Keep byebug working behind an adapter until the
  `debug` backend reaches parity.

## Plan

Each phase ends with something runnable and a clear exit criterion.

| Phase | Work | Exit criterion | Rough effort (one experienced dev) |
|---|---|---|---|
| **0. Spike** | Minimal `UI_Base` subclass: draw the source screen on `:suspended`; map F7/F8/F9 to `step`/`next`/`c` in `readline` | A script stops at `binding.break`, shows the source screen, and steps with keys | A few days |
| **1. Backend interface** | Extract what `Session` and the screens need from the debugger (frames: file, line, self, class, binding, label; threads; navigation and step commands) and move the byebug code behind it | No behaviour change; the full suite is green on byebug | ~1 week |
| **2. `debug` backend** | Implement the interface on `debug`, selectable by config/env; screens unchanged | Integration suite runs on the `debug` backend; failures triaged | 1–2 weeks |
| **3. REPL on Reline** | Replace the Pry proxy/interceptor/commands for the `debug` backend; decide on the Pry-command story | Key bindings, history, pager and `jard` commands work on `debug` | 1–2 weeks |
| **4. Parity and polish** | Multi-thread behaviour, resizing, output redirection, filters via `skip_path`, fixture re-recording, docs | Suite green on both backends across the CI matrix; used day-to-day | 2–6 weeks |
| **5. Switch over** | Make `debug` the default; remove byebug, Pry and the adapter shims; major version bump | Released; byebug no longer a dependency | ~1 week |

Total: roughly **1–3 months** to parity, depending mainly on phase 3 decisions and how
much the fixtures need re-recording.

## Open questions

- Is losing Pry acceptable, or must `ls`/`cd`/`show-source` survive (rebuilt, or via
  `irb_console`)?
- Keep the byebug backend long-term for older Rubies, or drop it at the switch-over?
- Is there a stable enough way to read the suspended thread's frames from the session
  thread without custom thread-client requests? (Settle this in the phase 0 spike.)
- Should the port coincide with the gem rename (see
  [fork-release-strategy.md](fork-release-strategy.md))? A new major version is a natural
  moment to rename.
