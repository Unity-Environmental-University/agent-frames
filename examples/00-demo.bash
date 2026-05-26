#!/usr/bin/env bash
# 90-second narrated demo of agent-frames.
# Walks through opening a frame, taking strikes, hitting the auto-fire
# threshold, recovering, and closing — with commentary at each step.
#
# Usage: bash examples/00-demo.bash
# Self-cleans on exit.

set -u
FRAME="$(cd "$(dirname "$0")/.." && pwd)/bin/frame"
SESS="demo-$$-$(date +%s)"
export AGENT_FRAMES_SESSION="$SESS"
trap "rm -f $HOME/.agent_frames/$SESS.* 2>/dev/null" EXIT

# colors only if stdout is a tty
if [[ -t 1 ]]; then
  BOLD=$'\e[1m'; DIM=$'\e[2m'; CYAN=$'\e[36m'; YEL=$'\e[33m'; RST=$'\e[0m'
else
  BOLD=""; DIM=""; CYAN=""; YEL=""; RST=""
fi

say() { echo; echo "${CYAN}${BOLD}$1${RST}"; }
note() { echo "${DIM}$1${RST}"; }
do_cmd() { echo "${YEL}\$ frame $*${RST}"; "$FRAME" "$@"; }
pause() { [[ -t 0 ]] && { read -rp "${DIM}[enter]${RST}" _; } || sleep 1; }

# ────────────────────────────────────────────────────────────────

say "agent-frames — 90s demo"
note "A frame is a subject-position. Opening one establishes WHERE you are working."
note "Weights accumulate. When W exceeds e ≈ 2.718, the frame auto-whelps and pops."
pause

say "1. Open a root frame"
do_cmd root fix "demo-debugging-a-flaky-test"
pause

say "2. Try something, evaluate honestly"
do_cmd try "rerun-test-to-confirm-flakiness"
note "Strict mode: you must eval the prior try before starting the next."
do_cmd eval strike "test-failed-again-but-different-error"
note "Strike recorded. Weight now 1.0 out of e ≈ 2.718."
pause

say "3. Inspect: read the bar"
do_cmd in
note "The bar shows accumulated weight. local + inherited = total."
pause

say "4. Take a tight swing — second hypothesis"
do_cmd try "check-for-shared-state-between-tests"
do_cmd eval strike "no-shared-state-found-still-flaky"
do_cmd in
note "W=2.0. The CLI is about to warn that one more strike will fire."
pause

say "5. Open a Circle — pre-Fix regulation"
note "Before another swing, deliberately step into F*ck-Around mode."
note "Strikes inside a circle don't count toward weight. The circle warns."
do_cmd circle "what-am-I-missing-about-this-test"
do_cmd circle-strike "tangent-checked-test-isolation"
do_cmd circle-strike "tangent-checked-system-clock"
do_cmd circle-strike "tangent-checked-network-timing"
do_cmd circle-status
note "Three tangents, circle saturating, but no auto-fire. You stay in control."
pause

say "6. Found something! Close the circle ready"
do_cmd ready "fix-test-to-use-fake-clock"
note "Circle resolved. The next move is in your hands."
pause

say "7. Final attempt"
do_cmd try "patch-test-with-fake-clock"
do_cmd eval success "test-passes-consistently-now"
do_cmd in
note "Resolved. The fix worked. Weight didn't matter — the third try landed."
pause

say "8. Declare the legacy and close"
do_cmd perish as method "fake-clock-pattern-applies-to-other-flaky-tests"
do_cmd resolve "flaky-test-fixed-with-fake-clock"
do_cmd sheet
pause

say "Demo complete."
note "Real work, real signal, real stop conditions."
note "Read CONCEPTS.md for the mechanism. See examples/01-first-frame.md for a fuller walk."
echo
