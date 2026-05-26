#!/usr/bin/env bash
# Full Zerg-mode demo: economy + recursive algedonic hubs.
#
# Shows:
#   1. The hatchery can't spawn zerglings without minerals
#   2. Drones earn minerals doing chores
#   3. Hatchery can now afford zerglings
#   4. Sub-overlord supervises lings, meta-overlord supervises sub-overlord
#   5. When a ling fires, pain propagates all the way up the hub chain
#
# Usage: bash examples/03-economy-and-hubs.bash

set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FRAME="$ROOT/bin/frame"
ECON="$ROOT/bin/frame-economy"
OVERLORD="$ROOT/bin/frame-overlord"
SESS="zergdemo-$$"
META="meta-$SESS"
SUB="sub-$SESS"
export AGENT_FRAMES_SESSION="$SESS"

trap "rm -rf $HOME/.agent_frames/$SESS.* $HOME/.agent_frames/overlord-$META $HOME/.agent_frames/overlord-$SUB 2>/dev/null" EXIT

if [[ -t 1 ]]; then BOLD=$'\e[1m'; DIM=$'\e[2m'; CYAN=$'\e[36m'; YEL=$'\e[33m'; RST=$'\e[0m'
else BOLD=""; DIM=""; CYAN=""; YEL=""; RST=""; fi
say() { echo; echo "${CYAN}${BOLD}$1${RST}"; }
note() { echo "${DIM}$1${RST}"; }
sec() { sleep 1; }

# ────────────────────────────────────────────────────────────────

say "Full Zerg demo: economy + algedonic hubs"
note "Hatchery, drones, zerglings, overlords. Mineral cost + recursive supervision."
sec

say "1. Open the hatchery (root frame)"
"$FRAME" root fix "demo-hatchery" >/dev/null
"$FRAME" in | head -4
sec

say "2. Try to spawn a zergling with 0 minerals"
note "Zerglings cost 3. We have 0. The system refuses."
"$ECON" spawn zergling "build-something" 2>&1 | head -4
sec

say "3. Send a drone to do a chore (drones are free)"
note "Drones earn 1 mineral per honest chore landed."
"$ECON" spawn drone "fix-typo-in-comment" 2>&1 | head -3
DRONE=$("$FRAME" in | grep current | awk '{print $2}')
note "Drone is now the current frame. In real use, the sub-agent would actually fix the typo."
note "Simulating an honest completion:"
"$FRAME" perish as evidence "fixed-typo-in-bin-frame" >/dev/null
"$ECON" deposit 1 "$DRONE" "fixed-typo-in-bin-frame" | head -1
"$FRAME" resolve "typo-fixed" >/dev/null
sec

say "4. Need 2 more chores"
"$ECON" spawn drone "remove-dead-import" 2>&1 | head -1
"$FRAME" perish as evidence "removed-dead-import" >/dev/null
"$ECON" deposit 1 "$(awk -F'\t' '/drone-ling-remove/ {print $1; exit}' "$HOME/.agent_frames/$SESS.frames.tsv")" "removed-dead-import" | head -1
"$FRAME" resolve "import-gone" >/dev/null
"$ECON" spawn drone "tighten-test-assertion" 2>&1 | head -1
"$FRAME" perish as evidence "test-now-actually-asserts" >/dev/null
"$ECON" deposit 1 "$(awk -F'\t' '/drone-ling-tighten/ {print $1; exit}' "$HOME/.agent_frames/$SESS.frames.tsv")" "test-now-actually-asserts" | head -1
"$FRAME" resolve "honest-test" >/dev/null
note "Balance now:"
"$ECON" minerals | head -1
sec

say "5. NOW spawn a zergling (cost 3, balance 3)"
"$ECON" spawn zergling "add-new-cli-subcommand" 2>&1 | head -4
ZERG=$("$FRAME" in | grep current | awk '{print $2}')
note "Balance after spend:"
"$ECON" minerals | head -1
sec

say "6. Set up the algedonic hub chain"
note "Sub-overlord supervises the zergling."
note "Meta-overlord supervises the sub-overlord."
note "Pain at the ling flows up TWO levels."
FRAME_OVERLORD="$SUB" "$OVERLORD" init "sub-swarm" >/dev/null
FRAME_OVERLORD="$SUB" "$OVERLORD" supervise ling "$ZERG"
FRAME_OVERLORD="$META" "$OVERLORD" init "meta-swarm" >/dev/null
FRAME_OVERLORD="$META" "$OVERLORD" supervise overlord "$SUB"
echo
echo "current state:"
FRAME_OVERLORD="$SUB" "$OVERLORD" supervised
echo
FRAME_OVERLORD="$META" "$OVERLORD" supervised
sec

say "7. Zergling takes 2 strikes (still alive)"
"$FRAME" strike "feature-attempt-1-wrong" >/dev/null
"$FRAME" strike "feature-attempt-2-also-wrong" >/dev/null
echo "  zergling W now:"
"$FRAME" in | grep weight
echo "  sub-overlord W now:"
FRAME_OVERLORD="$SUB" "$OVERLORD" overlord-w
echo "  meta-overlord W now:"
FRAME_OVERLORD="$META" "$OVERLORD" overlord-w
note "Pain has propagated up TWO levels. Meta-overlord can see the swarm is stressed."
sec

say "8. Third strike — zergling fires"
"$FRAME" strike "feature-attempt-3-fires" 2>&1 | tail -2
echo
echo "  ling stack now:"
"$FRAME" in | head -1
echo "  meta-overlord still sees the pain (institutional memory):"
FRAME_OVERLORD="$META" "$OVERLORD" supervised
sec

say "9. Warn for future spawns"
"$ECON" warn zergling "$ZERG" "feature-needed-clearer-requirements"
echo
"$ECON" warnings
sec

say "10. Balance: zergling fired, no refund"
"$ECON" minerals | head -1
note "Failed work doesn't pay. We're back at 0 minerals and have a warning to learn from."
sec

say "Demo complete."
note "The pathetic governance held: economy controls what CAN be attempted,"
note "FAFO loop controls what ACTUALLY happens. Algedonic hubs propagate pain"
note "recursively up any number of overlord layers."
echo
