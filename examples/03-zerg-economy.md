# Zerg economy with recursive algedonic hubs

A mineral economy on top of agent-frames, where:

- **Drones** mine minerals by doing **chores** (hardening, docs, DRY, legibility passes, test honesty)
- **Zerglings, hydralisks, mutalisks** spend minerals to build **features**
- **Overlords** are algedonic hubs — they aggregate strikes across the units they supervise
- **Overlords can supervise other overlords**, recursively — pain propagates up the hub chain
- The **hatchery** can refuse to spawn when:
  - mineral balance < cost (can't afford it), OR
  - the relevant overlord is saturated (can't supervise it honestly)

The pathetic-governance property holds: **the economy cannot override the FAFO loop**. A ling that fires deposits nothing. A ling that whelps deposits nothing. Only honest completions touch the ledger.

## The runnable demo

```bash
bash examples/03-economy-and-hubs.bash
```

Walks through: zergling refused with 0 minerals → 3 drones earn → zergling spawned → ling takes 3 strikes → fires at W>e → 2-level overlord chain shows pain propagating all the way up.

## The CLIs

`bin/frame-economy` runs the mineral side:

```bash
frame-economy minerals                      # show balance + recent activity
frame-economy spawn <type> <task>           # spawn a ling (cost-checked)
frame-economy deposit <amount> <source> <note>  # drone deposits earned
frame-economy spend <amount> <ling> <note>      # internal — auto-called on spawn
frame-economy ledger                        # full ledger dump
frame-economy ling-types                    # list ling types + costs
frame-economy warnings                      # salt-warnings from fired lings
frame-economy warn <type> <id> <note>       # ling-side: record honest failure
```

`bin/frame-overlord` runs the orchestration side (existing, now with recursive supervision):

```bash
frame-overlord init <swarm-name>            # establish overlord identity
frame-overlord supervise <kind> <id>        # add ling/drone/overlord to supervision
                                             # KEY MOVE: supervise an overlord for recursive hubs
frame-overlord supervised                   # show supervised units + each W + aggregate
frame-overlord overlord-w                    # just the aggregate number
frame-overlord overlord-fire <reason>        # force-whelp all supervised + cascade to children
# (plus the older: spawn, workers, field, swarm-w, intervene, kill, watch, retire)
```

## Ling types and costs

| Type | Cost | Earns | Role |
|---|---|---|---|
| **drone** | 0 | +1 per chore | The mineral miners. Surgical chores only. |
| **zergling** | 3 | 0 | Small features. The basic feature unit. |
| **hydralisk** | 5 | 0 | Test work. Pricier because tests need judgment. |
| **mutalisk** | 7 | 0 | Cross-file pattern work. Expensive because broad. |
| **hatchery** | 10 | 0 | New infrastructure (new repo, new module). |

(These numbers are first-draft. Calibrate from use. The relationships matter more than the absolute values: a feature should cost what its future maintenance debt is worth.)

## Ling briefs

Each ling type has a markdown file in `lings/` that is the **spawn brief** — the contract for what that ling type does and doesn't do. `frame-economy spawn <type>` prints it. Sub-agents (Claude Code Task tool, sub-Claudes, Qwen) get briefed by pasting the output into their prompt.

- [`lings/drone.md`](../lings/drone.md) — the chore mining contract, with explicit "what is NOT a chore" boundary
- [`lings/zergling.md`](../lings/zergling.md) — the feature-building contract, with explicit "what is NOT zergling work"

When adding a new ling type: drop a brief in `lings/<type>.md`, add its cost to `ling_cost()` in `bin/frame-economy`. That's it.

## Algedonic hubs, the recursive part

Any overlord can supervise any unit, including other overlords:

```bash
# small swarm: one overlord watches lings
frame-overlord init small-swarm
frame-overlord supervise ling frame-zergling-1
frame-overlord supervise ling frame-zergling-2

# bigger swarm: meta-overlord watches sub-overlords
FRAME_OVERLORD=meta frame-overlord init meta-swarm
FRAME_OVERLORD=meta frame-overlord supervise overlord sub-1
FRAME_OVERLORD=meta frame-overlord supervise overlord sub-2
FRAME_OVERLORD=meta frame-overlord supervise overlord sub-3

# pain in any ling under any sub-overlord shows up in meta's aggregate:
FRAME_OVERLORD=meta frame-overlord overlord-w
```

This is **Beer's viable system model recursion** in shell form. Every level has the same shape. The system can grow without re-architecting.

The default aggregation is `max` (any one in trouble → felt at the top). Set `FRAME_OVERLORD_AGG=mean` for averaged.

## What does NOT exist yet

- **Automatic spawn refusal based on overlord saturation.** Right now the economy only checks mineral cost. The next step is: also check that the relevant overlord has W < some-threshold. Easy to add; not in v0.1.
- **Intervention budgets** (scarcity coordination — drones spending minerals to absorb a ling's strike).
- **Overlord-fire auto-trigger** when overlord-W > e. Currently you have to call `overlord-fire` manually.
- **Decay of frame W over time.** Once a ling fires, its overlord still sees the pain forever (institutional memory). Sometimes you want that; sometimes you want the memory to fade.

These are all known-and-deferred for v0.1.

## A real workflow

The intended use: you sit down at Claude. You're the hatchery. The repo's mineral balance reflects whether the codebase is sustainable. You open a frame, decide what kind of work it is, and either:

- **Send a drone** if it's chore-shaped → +1 mineral
- **Spawn a zergling** if it's feature-shaped → -3 minerals, must work honestly or fire

When you spawn parallel sub-agents, you create overlords to watch them. When the swarm gets large, you create meta-overlords. When pain shows up at the top of the hub chain, you know: the system is over its capacity to supervise honestly. Stop spawning. Send drones to recover. Or accept that this work is too big for the current configuration and rebuild.

The economy is the rate-limit. The algedonic channel is the truth-teller. Together they're the metabolism of a sustainable codebase.
