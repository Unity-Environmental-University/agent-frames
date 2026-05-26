# Concepts

The mechanism in detail. Read this once before using the tool seriously; it's the difference between using `frame` as a verbose TODO list and using it as an actual signal.

## Frames

A frame is a **subject-position** — a perspective you adopt while doing work. The same task ("debug this test") feels different from inside a Fix frame than from inside a F\*ck Around frame, because the success criterion is different.

Five frame types:

| Frame | Question | Success criterion | When to use |
|---|---|---|---|
| **Step 0** | "How is it going?" | Accurate read | At the start; when disoriented |
| **F\*ck Around** | "What's interesting here?" | Interestingness, not progress | When lost; when a hypothesis fired and you need fresh data |
| **Fix** | "Can the thing work?" | Thing works | When you have a hypothesis worth testing |
| **Chill Vibes** | "Is rest the work?" | Not acting | When the right move is to wait |
| **Whelp** | "Is this path done?" | Honest acknowledgment | When you've given up — explicitly, with a reason |

The CLI doesn't enforce types. You self-declare. Picking the wrong type is its own diagnostic: if you keep opening Fixes when you should be in F\*ck Around, your strike threshold will feel too low.

## Moves

Nine moves. Master `try` / `eval` first; the rest fall out.

| Move | What it does |
|---|---|
| `try <action>` | Record an attempt. Refuses if the prior try is unevaluated. |
| `eval success\|strike\|emergency [note]` | Evaluate the prior try. Required before the next try. |
| `strike <cause>` | Shorthand: implicit try + eval as strike. |
| `emerge <cause>` | Algedonic emergency — fires straight to root, whelps frame. |
| `spawn <type> <because>` | Open a sub-frame. Warns if you're stressed. |
| `resolve <outcome>` | Close the frame as success. Pops to parent. |
| `whelp <reason>` | Close the frame as honest give-up. Pops to parent with strike-equivalent. |
| `intervene <kind> [note]` | Outside grace: absorb one local strike. Kinds: peer, user, sub-result, context, care-surface. |
| `pause <note>` / `resume <id>` | Set aside / pick back up. |

Plus three **Whitehead moves** for working with sub-agents (see [Whitehead moves](#whitehead-moves-circle-prehend-perish) below): `circle`, `prehend`, `perish`.

### Why `try` and `eval` are separate

The natural failure mode is collapsing them. You try something, it doesn't quite work, and you slide into the next attempt without explicitly naming what happened. Each "attempt" feels like progress; weight accumulates in your head as vague unease.

`try` records the attempt. `eval` forces you to name the result. The CLI refuses a second `try` while the first is unevaluated. **One try → one eval → next try.** This is the discipline that makes loops the right length.

## Weight mechanism

Every frame has a live weight, computed at read time:

```
W(frame) = (1/e) · W(parent_now) + local_strikes
```

Three things to absorb:

1. **Live, not frozen.** If the parent takes more strikes, the child's weight rises — without the child doing anything.
2. **`1/e ≈ 0.368`** is the coupling constant. A chain of N frames inherits `(1/e)^N` of root pressure — rapid attenuation but never zero.
3. **Fire threshold: W > e ≈ 2.718.** When crossed, the frame algedonic-fires to root with full decomposition (local vs inherited) and auto-whelps. The CLI does this for you.

### Why `e`?

Not arithmetic, not numerology — **human factors**. The challenge/skill ratio in Csíkszentmihályi's flow theory, the saturation point of a leaky integrator with `1/e` coupling, and the zone where attention sharpens before it shatters all cluster around the `e`-fold point.

Three strikes is approximately "you've taken three wrong swings and the system is forcing you to look up." Two strikes is "you've got room." Past three, accumulation is outpacing dissipation.

**`e` is not universal.** It's the *headroom available to this subject in this context*. Subjects carrying chronic upstream stress have permanently-nonzero inherited weight, so their effective `e` is smaller. **Privilege, structurally, is bandwidth for strikes.** The mechanism makes this legible rather than hiding it.

### Trauma-informed reading (optional)

A child of a stressed parent is **structurally tighter-tolerance**. The child isn't being *punished* for the parent's state — the child is *inside* the parent's stress field. Algedonic fire from a stressed-context child reads conditions, not personal failure.

Two failure modes the mechanism prevents:

- **Suppression**: inner frame swallows its pain, outer subject marches toward whelp without knowing.
- **Spam**: every minor inner discomfort fires the channel, outer subject develops calluses and ignores the channel.

`1/e` fractional propagation provides the dampening; only weight that survives the decay reaches root.

## Whitehead moves: circle, prehend, perish

Three moves added to cover the full temporal arc of a frame's becoming (Whitehead's vocabulary: each occasion *concresces* by prehending prior data and then *perishes* into data for what comes next).

### `circle <about>` — pre-prehension of future shape

Open before a Fix you know will be hard, to *arrive loose*. Success criterion is regulation, not progress. Tangents (via `circle-strike`) accumulate in a side log and warn at 3 *without* auto-firing — the circler stays in control.

This is the only frame type where auto-fire is suppressed. Subject-positions can have different algedonic semantics on the same underlying weight math: Fix says "stop me if I'm wrong"; Circle says "tell me if I'm wandering, I'll decide."

Close with `frame ready <next-step>` (arrived) or `frame circle-out <reason>` (this isn't actually a Fix).

### `prehend <target> as <kind> [note]` — explicit causal lineage

Declare that this frame is taking up some prior thing as its objective datum. Targets can be other frame IDs, file paths, or freeform handles. Kinds form a stable cross-time grammar:

| Kind | Meaning |
|---|---|
| `evidence` | "this is the receipt I'm building on" |
| `method` | "I'm using this approach/pattern" |
| `counter` | "I'm taking this as something to disprove" |
| `warning` | "this is a failure I'm avoiding" |
| `seed` | "I'm transforming this into something different" |
| `context` | "aware of this but not building on it" |
| `question` | "I'd take this up if it existed — escape hatch for missing targets" |

**The CLI refuses non-existent targets** unless declared `as question`. This closes the fabrication vector: a sub-agent cannot claim to have read something it hasn't.

### `perish as <kind> [note]` — typed legacy

Type what this frame leaves for future readers. Same kinds as `prehend`, plus `receipt`. Additive — call before `resolve` or `whelp`.

The shared vocabulary between `prehend` and `perish` is the **cross-time protocol**: a frame that perished-as-method enables a future frame to prehend-as-method.

### The asymmetry to know

Requiring sub-agents to declare prehensions shifts work *upward*, to the spawning parent. **The parent has to know what artifacts exist before spawning.** A sub-agent fabrication is, structurally, the parent's failure to provide the prehension list — not the sub-agent's failure to be careful. Use `frame brief --prehends <target:kind,...>` to bake the requirement into the brief itself.

## Spawning sub-agents

When you delegate to a Claude Code Task tool, a sub-process, or any other agent:

1. Open the sub-agent's frame yourself with `frame spawn <type> <because>`.
2. Decide the prehensions first — what artifacts must the sub-agent take up to do this work honestly?
3. Run `frame brief --prehends <target:kind,...>` and paste the output into the sub-agent's prompt.
4. On return, **read the sub-agent's frame edges**, not just its summary. Missing `prehends-*` edges are a structural suppression signal — flag explicitly, do not paper over.
5. If you catch suppression: use `frame down <reason>` to descend into the suppressed frame yourself with tighter instruments.

## State

State lives in plain TSV files under `~/.agent_frames/<session-key>.{frames,strikes,tries,edges,circle-strikes}.tsv` plus `.current` and `.root` pointer files.

Session key = `$AGENT_FRAMES_SESSION` if set, else a hash of `pwd`. **Export it explicitly** when:

- spawning sub-processes that should share your stack
- using tools (like Claude Code's Bash) that wipe env between invocations

## Optional: rhizome integration

If you also use the [rhizome](https://github.com/anthropics/rhizome) knowledge graph (a separate project), set `FRAME_EDGE_BRIDGE=1` and `frame` will also write every edge to the graph. Default is self-contained TSVs only.

## When NOT to use this

- **Simple linear work.** Renaming a variable, answering a direct question. Frames are overhead.
- **When you want flow, not structure.** Sometimes the right move is to just code.
- **One-off shell commands.** The overhead exceeds the value.

If you find yourself using `frame` to track work that obviously doesn't need it, you're misframing. The signal is that the bar never moves and the moves feel ceremonial.
