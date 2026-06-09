#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# filter_coverage.sh — produce the "coverage of LOGIC" lcov report.
#
# Takes the raw `flutter test --coverage` output (coverage/lcov.info) and removes
# every NON-LOGIC source record listed in tool/coverage/coverage_excludes.txt,
# writing the filtered report to coverage/lcov.filtered.info.
#
# WHY a filter at all: the GA coverage target is "~99% of the LOGIC surface"
# (owner M5 mandate + CLAUDE.md D6). The denominator must therefore be human
# authored, host-testable logic — NOT generated code, NOT pure platform
# plumbing that can only run on a device. Each excluded glob is a line item in
# coverage_excludes.txt with a one-sentence justification; the exclusion list is
# the single source of truth read by this script and by the floor gate.
#
# HONESTY CONTRACT: an exclusion is only ever for code that has NO host-testable
# logic. A file that contains parsing / state / fallback decisions stays in the
# denominator even if it is currently untested — that is a coverage gap for
# C6/C7 to close, never something to hide behind an exclusion.
#
# Identical locally and in CI: CI installs `lcov` (apt) and calls this script;
# locally it falls back to the vendored perl `lcov` if `lcov` is not on PATH.
# The exclusion globs are matched against the lcov `SF:` paths (repo-relative,
# e.g. `lib/data/db/database.g.dart`).
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
RAW="${REPO_ROOT}/coverage/lcov.info"
OUT="${REPO_ROOT}/coverage/lcov.filtered.info"
EXCLUDES_FILE="${SCRIPT_DIR}/coverage_excludes.txt"

if [ ! -f "${RAW}" ]; then
  echo "filter_coverage.sh: no ${RAW} found — run 'flutter test --coverage' first" >&2
  exit 1
fi
if [ ! -f "${EXCLUDES_FILE}" ]; then
  echo "filter_coverage.sh: missing ${EXCLUDES_FILE}" >&2
  exit 1
fi

# Read the exclusion globs: skip blank lines and `#` comments. The remaining
# tokens are passed verbatim to `lcov --remove` (each is a glob over SF paths).
mapfile -t GLOBS < <(grep -vE '^\s*(#|$)' "${EXCLUDES_FILE}" | sed -E 's/\s+#.*$//' | awk 'NF{print $1}')
if [ "${#GLOBS[@]}" -eq 0 ]; then
  echo "filter_coverage.sh: no exclusion globs in ${EXCLUDES_FILE}" >&2
  exit 1
fi

echo "filter_coverage.sh: removing ${#GLOBS[@]} exclusion glob(s) from coverage:"
for g in "${GLOBS[@]}"; do echo "  - ${g}"; done

# Resolve an lcov invocation: system `lcov` (CI) or vendored perl `lcov` (local).
lcov_cmd() {
  if command -v lcov >/dev/null 2>&1; then
    lcov "$@"
  elif [ -n "${LCOV_BIN:-}" ] && [ -x "${LCOV_BIN}" ]; then
    perl "${LCOV_BIN}" "$@"
  else
    echo "filter_coverage.sh: no 'lcov' on PATH and LCOV_BIN unset" >&2
    return 127
  fi
}

# `lcov --remove <tracefile> <pattern...>` drops every record whose SF path
# matches any pattern. `--ignore-errors unused` tolerates a glob that matches
# nothing (e.g. *.freezed.dart when none exist yet) without failing the build.
lcov_cmd \
  --remove "${RAW}" "${GLOBS[@]}" \
  --output-file "${OUT}" \
  --ignore-errors unused,unused \
  --rc branch_coverage=0 \
  >/dev/null

echo "filter_coverage.sh: wrote ${OUT}"
