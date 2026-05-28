# Example 1 — Your first frame, walked through

A 15-minute walkthrough for a stranger. We'll debug a (hypothetical) flaky test together, using `frame` to track the work. By the end you'll have used every move that matters in real work.

## Setup

```bash
# from anywhere
export AGENT_FRAMES_SESSION=my-first-frame
frame root fix "debug-the-flaky-auth-test"
```

You should see something like:

```
root opened: frame-debug-the-flaky-auth-test-1779816000 (fix)
```

You've opened a root **Fix** frame. The session is in your hands now.

## Run `frame in` whenever you want to read the bar

```bash
frame in
```

```
current: frame-debug-the-flaky-auth-test-1779816000
  type:    fix
  parent:  ROOT
  state:   open
  opened:  13:30:00  (0s ago)
  weight:  ▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱  0.0000 / 2.718281828459045  (0%)
           local=0  inherited=0.0000
```

W=0. You have full slack.

## Make a try; evaluate it honestly

Your aim: the flaky auth test is a race condition. You re-run it 5 times to confirm flakiness.

```bash
frame try "rerun-auth-test-5x-to-confirm-flakiness"
```

Suppose 3 of 5 fail. The test IS flaky. The try succeeded as an investigation, but the test failed — so what's the eval?

This is where the distinction matters. The **try** was "rerun the test 5x". That succeeded — you got data. So:

```bash
frame eval success "confirmed-flaky-3-of-5-fail-with-different-errors"
```

Note the note: not just "success" but *what* you learned. The note is for future-you.

## First aim: race condition

```bash
frame try "add-explicit-sync-around-auth-token-mutation"
```

Run the test 10 times with your fix. Still flaky.

```bash
frame eval strike "still-3-of-10-fail-sync-didnt-help-not-a-race"
```

```
✗ strike on add-explicit-sync-around-auth-token-mutation (still-3-of-10-fail-sync-didnt-help-not-a-race) → W(...)=1.0000
```

W=1. One aim that missed.

## Second aim: clock drift

```bash
frame try "check-if-test-relies-on-system-time-and-mock-it"
```

You add a fake clock. Run 10 times. Still flaky.

```bash
frame eval strike "still-2-of-10-fail-not-clock-related"
```

```
✗ strike on check-if-test-relies-on-system-time-and-mock-it (still-2-of-10-fail-not-clock-related) → W(...)=2.0000
```

W=2. Two aims that missed. You're 73% to the threshold.

Run `frame in`:

```
  weight:  ▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▱▱▱▱▱  2.0000 / 2.718281828459045  (73%)
           local=2  inherited=0.0000
```

**This is the moment.** Your instinct will say "third time's the charm". The bar is saying you're running out of slack.

## Try to take a third swing — see what happens

```bash
frame try "maybe-its-a-database-isolation-problem"
```

```
⚠ W=2.0000 — a single strike here would fire (W+1 > e). take a tight, reversible swing.
tried: maybe-its-a-database-isolation-problem  (unevaluated)
```

The CLI warned you. It didn't stop you, but it told you: one more strike fires.

You have three honest choices:

1. **Take a tight, surgical swing**: actually probe the database, don't just guess.
2. **Open a Circle**: step back, look around, see what you're missing.
3. **Whelp**: admit you're on the wrong track and reset.

Let's try option 2.

## Step into a Circle for regulation

First, eval the pending try as a strike — you didn't actually test the DB aim, you were just about to:

```bash
frame eval strike "didnt-actually-test-just-second-guessing"
```

```
✗ strike on maybe-its-a-database-isolation-problem (...) → W(...)=3.0000
⚠ W=3.0000 > e=2.718281828459045 — algedonic emergency firing
→ root whelped. stack empty.
```

**The frame auto-fired.** You crossed `e`. The mechanism popped you out.

This is the gift. You were about to spend an hour on a database aim you hadn't even tested. The system stopped you.

## Restart fresh — this time with a Circle first

```bash
frame root fix "debug-flaky-test-take-2"
frame circle "what-am-I-actually-missing-here"
```

A Circle is a deliberate F\*ck Around. Strikes inside don't count toward weight. The success criterion is *arriving loose*, not progress.

```bash
frame circle-strike "looked-at-test-output-more-carefully"
frame circle-strike "diff-the-passing-runs-against-failing-ones"
frame circle-strike "noticed-failures-correlate-with-time-of-day"
```

```
circle-tangent 1 on ... 
circle-tangent 2 on ...
circle-tangent 3 on ...
  ⚠ 3 tangents — circle saturating. consider 'frame ready' or 'frame circle-out'.
  (warning, not fire. you stay in control.)
```

Three tangents — the circle warns, but doesn't auto-fire. You're still in control. And tangent 3 — "failures correlate with time of day" — gives you a real lead.

```bash
frame ready "test-uses-timezone-aware-comparison-and-DST-just-ended"
```

The circle resolves. Now a fresh Fix with the right aim:

```bash
frame try "patch-test-to-use-UTC-explicitly"
frame eval success "100-passes-in-a-row-it-was-DST"
```

## Declare the legacy

You found a real pattern. Future-you (or a teammate) might hit this again. Type the legacy:

```bash
frame perish as method "DST-and-timezone-flakiness-pattern-check-test-for-time-comparisons"
frame resolve "flaky-auth-test-fixed-was-DST-transition"
```

```
perished: frame-debug-flaky-test-take-2-... as method (DST-and-timezone-flakiness-pattern-check-test-for-time-comparisons)
resolved root frame-debug-flaky-test-take-2-... (flaky-auth-test-fixed-was-DST-transition). stack empty.
```

## What just happened

You used the system on a real-shape problem:

- **The fire saved you** from a third strike on an aim that wasn't landing
- **The circle let you regulate** before another swing — found the real signal in a tangent
- **The perish typed the legacy** so future readers know to check timezone comparisons in flaky tests

That's the loop. The mechanism is doing real work, not bookkeeping.

## Try it on your own next real problem

The next time you sit down to debug something where you suspect you'll take aim 2+ times and miss, open a frame:

```bash
frame root fix "<short-description>"
```

…and let the bar tell you when you're sinking too much into the wrong frame. The fire is the gift.

## Where to go next

- [CONCEPTS.md](../CONCEPTS.md) — the full mechanism, kinds vocabulary, sub-agent integration
- [00-demo.bash](00-demo.bash) — the runnable 90-second narration
- Run `frame brief` to print a sub-agent briefing — useful when delegating to Claude Code Task tool or similar
