# Zerg mode — overlord-coordinated swarms

A `frame-overlord` CLI for orchestrating swarms of independent `frame` workers, with swarm-level algedonic awareness.

The mechanism in one paragraph: **workers are independent `frame` sessions** (each with its own `AGENT_FRAMES_SESSION`) producing state at `~/.agent_frames/*.tsv`. **The overlord reads workers' state files** to compute an aggregated swarm-W, fire at a swarm-level threshold, dispatch interventions, and force-whelp stuck workers. Workers do not know about each other. The overlord is overlay, not entanglement.

This honors the substrate: subject-positions remain isolated; coordination is something *added on top* by an outside intelligence.

## When to use it

- You're spawning N parallel sub-agents on a task and want one place to watch their collective state
- You want to *intervene* on a struggling worker (absorb a strike) without that worker having to ask
- You need to *kill* workers whose task became obsolete
- You want a "fire when the swarm is over threshold" signal, not just individual worker fires

## The runnable demo

```bash
bash examples/02-zerg-demo.bash
```

Spawns 3 workers, walks through strikes/interventions/force-whelps, shows the swarm-W aggregating live.

## The moves

```bash
frame-overlord init <swarm-name>             # establish overlord identity
frame-overlord spawn <worker-name>            # register a worker
frame-overlord workers                        # list registered
frame-overlord field                          # show all workers + their Ws (bars)
frame-overlord swarm-w [--mode max|sum]       # compute aggregated W
frame-overlord intervene <worker> <kind> [note]   # absorb a strike on worker
frame-overlord kill <worker> <reason>         # force-whelp worker stack
frame-overlord watch [--interval Ns]          # live field, refresh every N seconds
frame-overlord retire                         # close overlord; workers continue
```

## Environment

| Variable | Default | Meaning |
|---|---|---|
| `FRAME_OVERLORD` | `default` | Overlord identity; lets you run multiple swarms |
| `FRAME_SWARM_THRESHOLD_MULT` | `1.5` | Swarm fires when swarm-W exceeds `MULT × e` |

## How workers integrate

A worker is just a regular `frame` session with a session key the overlord registered:

```bash
# overlord side
frame-overlord spawn alice
# prints: session key: worker-<swarm>-alice

# worker side (could be another shell, another machine, a sub-Claude)
export AGENT_FRAMES_SESSION=worker-<swarm>-alice
frame root fix "alice-task"
frame try "..."
# ... normal frame work ...
```

The overlord watches alice's state files appear and update.

## The swarm-W aggregation modes

- `--mode max` (default): swarm-W = max worker W. Triggers when *any* worker is saturating. Right for "stop if any one is in trouble."
- `--mode sum`: swarm-W = sum of worker Ws. Triggers when collective load is high even if no individual is at threshold. Right for "the swarm is collectively overworked."

Pick based on the failure mode that matters. `max` is the conservative default.

## What doesn't (yet) exist

- **Hierarchical overlords** (overlord-of-overlords for very large swarms)
- **Cross-worker prehension** (workers learning from each other's findings)
- **Intervention budgets** (scarcity-based coordination — the "monetary policy" idea)
- **Auto-fire** at the swarm level. Currently the overlord just *warns* via `watch`; you decide what to do. A more aggressive variant would auto-kill workers when swarm-W exceeds threshold.

These are intentional v0.1 omissions. The minimal core ships first; the rest can be built on top.

## A real use case

You're running a Claude Code session that spawns 5 parallel sub-agents to refactor different files. You want to:

1. See all 5 sub-agent stacks at once
2. Notice when one is struggling (high W)
3. Intervene by handing it more context (absorb a strike with `kind=context`)
4. Kill any that get stuck on the wrong refactor without burning your full session budget

Zerg mode is the substrate for this. You'd write a thin wrapper that translates "spawn sub-agent" into "register worker + invoke Claude with the worker's session key in the prompt." The overlord's `watch` view becomes your dashboard.

## Honest caveat

`frame-overlord` was prototyped in one session and shipped at v0.1 with one runnable demo. It hasn't been used on a real multi-process swarm yet. The substrate (TSV-based state, overlord polling) is right, but the ergonomics of actually wiring it to real sub-agents will need iteration. If you use it on real work and find friction, that's the next loop.
