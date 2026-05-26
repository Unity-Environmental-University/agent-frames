#!/usr/bin/env bash
# Smoke test for the standalone `frame` CLI.
# Exercises every move once in an isolated session and checks each one writes
# the expected state. Run from any directory; uses a unique session key.
#
# Usage: bash test/smoke.bash
# Exits 0 on full pass, non-zero on first failure.

set -u  # not -e: we want to count failures
# (no ERR trap — frame returns 1/2 for intended refusals; not failures of the test)

FRAME="$(cd "$(dirname "$0")/.." && pwd)/bin/frame"
SESS="smoke-$$-$(date +%s)"
STATE="$HOME/.agent_frames/$SESS"
export AGENT_FRAMES_SESSION="$SESS"

cleanup() { rm -f "$STATE".* 2>/dev/null; }
trap cleanup EXIT

PASS=0; FAIL=0
check() {
  local desc="$1" expected="$2" got="$3"
  if [[ "$got" == *"$expected"* ]]; then
    echo "  ✓ $desc"
    PASS=$((PASS+1))
  else
    echo "  ✗ $desc"
    echo "    expected substring: $expected"
    echo "    got: $got"
    FAIL=$((FAIL+1))
  fi
}

echo "smoke test for $FRAME"
echo "session: $SESS"
echo

echo "=== root + try/eval ==="
out=$("$FRAME" root fix "smoke-root" 2>&1)
check "root opens" "root opened" "$out"
out=$("$FRAME" try "first" 2>&1)
check "try registers" "unevaluated" "$out"
out=$("$FRAME" try "second-while-first-pending" 2>&1)
check "strict mode refuses concurrent try" "refusing" "$out"
out=$("$FRAME" eval success "good" 2>&1)
check "eval success" "✓ success" "$out"

echo "=== strike + weight ==="
out=$("$FRAME" strike "a-cause" 2>&1)
check "strike shorthand works" "✗ strike" "$out"
out=$("$FRAME" in 2>&1)
check "weight = 1.0 after one strike" "1.0000" "$out"

echo "=== circle + circle-strike (warns, no fire) ==="
out=$("$FRAME" circle "warmup" 2>&1)
check "circle opens" "circling" "$out"
out=$("$FRAME" circle-strike "tangent-1" 2>&1)
check "circle-strike accepted" "circle-tangent 1" "$out"
"$FRAME" circle-strike "tangent-2" >/dev/null 2>&1
out=$("$FRAME" circle-strike "tangent-3" 2>&1)
check "circle warns at 3" "circle saturating" "$out"
out=$("$FRAME" in 2>&1)
check "circle weight stays 0" "local=0" "$out"
out=$("$FRAME" circle-status 2>&1)
check "circle-status shows tangents" "tangents: 3" "$out"

echo "=== prehend + ancestry ==="
out=$("$FRAME" prehend "$FRAME" as method "the-cli" 2>&1)
check "prehend real file works" "file-found" "$out"
out=$("$FRAME" prehend "/does/not/exist" as evidence "fake" 2>&1)
check "prehend refuses missing target" "refusing" "$out"
out=$("$FRAME" prehend "/does/not/exist" as question "honestly-missing" 2>&1)
check "prehend allows missing with as-question" "prehended" "$out"
out=$("$FRAME" ancestry 2>&1)
check "ancestry shows prehensions" "as-method" "$out"

echo "=== perish + ready (close circle) ==="
out=$("$FRAME" perish as receipt "smoke-receipts" 2>&1)
check "perish writes legacy edge" "perished" "$out"
out=$("$FRAME" ready "next-thing" 2>&1)
check "ready closes circle" "ready. next" "$out"

echo "=== intervene ==="
out=$("$FRAME" strike "another-strike-to-absorb" 2>&1)
out=$("$FRAME" intervene user "smoke-grace" 2>&1)
check "intervene absorbs a strike" "strike absorbed" "$out"

echo "=== brief --prehends ==="
out=$("$FRAME" brief --prehends "$FRAME:method,/tmp:context" 2>&1)
check "brief --prehends injects section" "REQUIRED PREHENSIONS" "$out"

echo "=== fire and recover (weight > e) ==="
"$FRAME" spawn fix "intentional-fire" >/dev/null 2>&1
"$FRAME" strike "s1" >/dev/null 2>&1
"$FRAME" strike "s2" >/dev/null 2>&1
out=$("$FRAME" strike "s3-should-fire" 2>&1)
check "auto-fires at W>e" "algedonic emergency firing" "$out"
out=$("$FRAME" in 2>&1)
check "popped back to parent" "smoke-root" "$out"

echo "=== close all ==="
"$FRAME" whelp "smoke-end" >/dev/null 2>&1
out=$("$FRAME" sheet 2>&1)
check "stack empty after whelp" "no current frame" "$out"

echo
echo "═══════════════════════════════════════════"
echo "  pass: $PASS  fail: $FAIL"
echo "═══════════════════════════════════════════"
[[ "$FAIL" -eq 0 ]] && exit 0 || exit 1
