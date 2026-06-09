#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# check_floor.sh — the coverage-of-LOGIC ratchet gate.
#
# Computes line coverage from the FILTERED lcov report (coverage/lcov.filtered.info,
# produced by filter_coverage.sh) and FAILS if it has dropped below the committed
# floor in tool/coverage/coverage_floor.txt.
#
# RATCHET, not target: the floor is the CURRENT measured baseline of
# coverage-of-logic. It only ever moves UP, and a commit that lowers
# coverage-of-logic below the stored floor reds the gate. The end goal is
# ~99%-of-logic (owner M5 mandate + CLAUDE.md D6); C6/C7 raise actual coverage
# toward it and bump this floor as they land, and C10 sets the final 99% target.
# DO NOT set the floor to 99% before the coverage exists — that would red the
# everyday CI. Bump the floor only AFTER the covering tests are committed.
#
# Pure-awk percentage compare (no `bc`, locale-independent): sums LF (lines
# found) and LH (lines hit) across all records, computes 100*LH/LF, and compares
# to the floor scaled to the same integer-hundredths precision so the gate is
# exact and deterministic.
#
# Usage:
#   tool/coverage/check_floor.sh                # gate against coverage_floor.txt
#   tool/coverage/check_floor.sh --floor 95.0   # gate against an explicit floor
#                                               #   (used to DEMONSTRATE the gate
#                                               #    reds when coverage < floor)
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
FILTERED="${REPO_ROOT}/coverage/lcov.filtered.info"
FLOOR_FILE="${SCRIPT_DIR}/coverage_floor.txt"

OVERRIDE_FLOOR=""
if [ "${1:-}" = "--floor" ]; then
  OVERRIDE_FLOOR="${2:?--floor needs a value}"
fi

if [ ! -f "${FILTERED}" ]; then
  echo "check_floor.sh: no ${FILTERED} — run filter_coverage.sh first" >&2
  exit 1
fi

if [ -n "${OVERRIDE_FLOOR}" ]; then
  FLOOR="${OVERRIDE_FLOOR}"
else
  if [ ! -f "${FLOOR_FILE}" ]; then
    echo "check_floor.sh: missing ${FLOOR_FILE}" >&2
    exit 1
  fi
  # First non-comment, non-blank token is the floor percentage.
  FLOOR="$(grep -vE '^\s*(#|$)' "${FLOOR_FILE}" | awk 'NF{print $1; exit}')"
fi

# Sum LF/LH and compare to the floor, all in awk. Coverage and floor are scaled
# to integer hundredths-of-a-percent (×100) so the `<` is exact integer math.
awk -F: -v floor="${FLOOR}" '
  /^LF:/ { lf += $2 }
  /^LH:/ { lh += $2 }
  END {
    if (lf == 0) {
      print "check_floor.sh: filtered report has 0 instrumented lines"
      exit 2
    }
    pct = 100.0 * lh / lf
    # Scale to hundredths and round to the nearest integer for an exact compare.
    pct_x100   = int(pct   * 100 + 0.5)
    floor_x100 = int(floor * 100 + 0.5)
    printf "Coverage of LOGIC: %.2f%%  (covered %d / %d lines; floor %.2f%%)\n", pct, lh, lf, floor
    if (pct_x100 < floor_x100) {
      printf "FAIL: coverage-of-logic %.2f%% is below floor %.2f%%\n", pct, floor
      exit 1
    }
    print "OK: coverage-of-logic meets the floor."
  }
' "${FILTERED}"
