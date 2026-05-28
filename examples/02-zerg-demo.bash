#!/usr/bin/env bash
# Zerg-mode demo: 3 workers, 1 overlord.
# Three workers each open a Fix frame and take some strikes.
# The overlord aggregates their weights into a swarm-W and intervenes.
#
# Usage: bash examples/02-zerg-demo.bash
# Self-cleans on exit.

set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FRAME="$ROOT/bin/frame"
OVERLORD="$ROOT/bin/frame-overlord"
SWARM="zerg-demo-$$-$(date +%s)"
export FRAME_OVERLORD="$SWARM"

trap "rm -rf $HOME/.agent_frames/overlord-$SWARM $HOME/.agent_frames/worker-$SWARM-* 2>/dev/null" EXIT

if [[ -t 1 ]]; then BOLD=$'\e[1m'; DIM=$'\e[2m'; CYAN=$'\e[36m'; RST=$'\e[0m'
else BOLD=""; DIM=""; CYAN=""; RST=""; fi
say() { echo; echo "${CYAN}${BOLD}$1${RST}"; }
note() { echo "${DIM}$1${RST}"; }
pause() { sleep 1; }

# ────────────────────────────────────────────────────────────────

say "Zerg-mode demo: 1 overlord, 3 workers"
note "Workers are independent frame sessions. Overlord aggregates weights."
pause

say "1. Initialize the overlord"
"$OVERLORD" init "$SWARM"
pause

say "2. Spawn 3 workers (alice, bob, carol)"
"$OVERLORD" spawn alice
"$OVERLORD" spawn bob
"$OVERLORD" spawn carol
pause

say "3. Each worker opens a Fix frame and gets to work"
for name in alice bob carol; do
  SK="worker-$SWARM-$name"
  AGENT_FRAMES_SESSION="$SK" "$FRAME" root fix "$name-task" >/dev/null
done
"$OVERLORD" field
note "All workers at W=0. Swarm-W is 0."
pause

say "4. Alice and bob take a strike each. Carol is fine."
SK_A="worker-$SWARM-alice"
SK_B="worker-$SWARM-bob"
AGENT_FRAMES_SESSION="$SK_A" "$FRAME" strike "alice-first-aim-missed" >/dev/null
AGENT_FRAMES_SESSION="$SK_B" "$FRAME" strike "bob-first-aim-missed" >/dev/null
"$OVERLORD" field
note "Alice and bob at W=1.0. Carol still 0. Swarm-W (max): $("$OVERLORD" swarm-w)"
pause

say "5. Alice takes a second strike — getting close to threshold"
AGENT_FRAMES_SESSION="$SK_A" "$FRAME" strike "alice-second-aim-also-missed" >/dev/null
"$OVERLORD" field
note "Alice at W=2.0 (73% of e). Swarm-W now: $("$OVERLORD" swarm-w)"
pause

say "6. Overlord intervenes on alice — absorb one strike (peer help arriving)"
"$OVERLORD" intervene alice peer "overlord-noticed-alice-stressed"
echo
"$OVERLORD" field
note "Alice dropped to W=1.0. The overlord's care propagated structurally."
pause

say "7. Bob takes two more strikes — bob fires"
AGENT_FRAMES_SESSION="$SK_B" "$FRAME" strike "bob-second-wrong" >/dev/null 2>&1
AGENT_FRAMES_SESSION="$SK_B" "$FRAME" strike "bob-third-fires" 2>&1 | tail -3
echo
"$OVERLORD" field
note "Bob auto-fired and his stack is empty. He's done."
pause

say "8. Overlord kills carol — discovered her task is no longer needed"
"$OVERLORD" kill carol "task-cancelled-upstream-decision"
echo
"$OVERLORD" field
pause

say "9. Final swarm-W"
echo "swarm-W (max): $("$OVERLORD" swarm-w)"
echo "swarm-W (sum): $("$OVERLORD" swarm-w --mode sum)"
note "Only alice still has open work. The swarm has cooled."
pause

say "10. Retire the overlord"
"$OVERLORD" retire
echo
note "Workers' state files remain — alice can keep going independently."
note "The overlord layer is overlay, not entanglement."

say "Demo complete."
note "In real use, overlords would run 'frame-overlord watch' for live monitoring,"
note "and workers would be separate processes (or sub-Claudes, or even Qwen)."
echo
