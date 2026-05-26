# agent-frames

A small command-line tool for tracking debugging and design work as a stack of **subject-positions** — perspectives like "I'm exploring", "I'm trying to fix this", "I'm regulating before a hard attempt" — with a built-in stop condition that fires when you've sunk too much into the wrong hypothesis.

In one line: a state machine for staying honest about how stuck you are.

## See it work

```bash
git clone <this-repo> agent-frames
cd agent-frames
bash examples/00-demo.bash
```

90 seconds. No setup. Walks you through opening a frame, taking strikes, hitting the auto-fire threshold, and recovering.

## Why this exists

You're debugging a flaky test. Your first hypothesis is wrong, your second hypothesis is wrong, you keep refining the same wrong frame because each adjustment feels like progress. Two hours later you discover the bug was in a completely different layer.

This is normal. It's also avoidable. The pattern is:

- you take a try
- it doesn't work
- you don't *evaluate* — you slide into the next attempt with the same mental model
- weight accumulates without your noticing
- eventually you realize you've been on the wrong path for an hour

agent-frames separates **trying** from **evaluating**, accumulates a visible weight number, and **forcibly pops you out of the frame when weight exceeds e ≈ 2.718** — a threshold borrowed from flow theory and leaky-integrator math. The fire is the gift: it stops you from spending a third strike defending the wrong frame.

## What's in the box

Five frame types (Step 0, F\*ck Around, Fix, Chill Vibes, Whelp), nine moves (try, eval, strike, emerge, spawn, intervene, resolve, whelp, circle), live weight inheritance (children of stressed parents have less slack — structurally, not metaphorically), and explicit causal lineage via `prehend` and `perish` for working with sub-agents.

A 700-line bash script with no dependencies beyond `bash`, `awk`, `sed`, `date`, `shasum`, `python3` (most systems already have these). State lives in plain TSV files under `~/.agent_frames/`.

## Install

```bash
git clone <this-repo> ~/agent-frames
ln -s ~/agent-frames/bin/frame ~/.local/bin/frame
# (ensure ~/.local/bin is in your PATH)
```

See [INSTALL.md](INSTALL.md) for more options.

## Learn

- [CONCEPTS.md](CONCEPTS.md) — the mechanism: frames, moves, weight math, kinds vocabulary, when to use, when not to
- [examples/01-first-frame.md](examples/01-first-frame.md) — a fuller worked example
- [examples/00-demo.bash](examples/00-demo.bash) — the runnable demo
- [examples/02-zerg-mode.md](examples/02-zerg-mode.md) + [examples/02-zerg-demo.bash](examples/02-zerg-demo.bash) — overlord-coordinated swarms of workers

## When to use it

- You're about to debug something where you'll likely chase 2+ wrong hypotheses
- You're spawning sub-agents (Claude Code Task tool, etc.) on work that could fail in non-obvious ways
- You've noticed you have a habit of giving up too early *or* burning too much time on the wrong path
- You want a graph of how you arrived at a fix that survives the session

## When NOT to use it

- Simple linear work — renaming a variable, answering a direct question
- When you want flow, not structure
- One-off shell commands where the overhead exceeds the value

## License

MIT — see [LICENSE](LICENSE).

## Credit

Built with [Claude](https://claude.com/) (Opus 4.7, 1M context) in a session that included building a Mario game to test the mechanism. The Mario build hit the auto-fire threshold, popped me out of a wrong hypothesis (`requestAnimationFrame` throttling in hidden tabs, not a module-loading bug), and produced both the working game and this tool. The receipt for that arc is the original motivation.
