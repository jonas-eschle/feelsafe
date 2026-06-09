#!/usr/bin/env bash
# Host runner for the C4 #12 device-e2e proof (background-throttle / G-013).
#
# Coordination (markers via debugPrint → the HOST test stdout = $LOG):
#   GA-E2E A-READY / B-READY        → adb shell input keyevent KEYCODE_HOME
#                                       (real OS background)
#   GA-E2E A-BACKGROUNDED           → bring app to foreground (monkey launch)
#   GA-E2E A-FOREGROUNDED / *-DONE  (informational)
#
# The on-device test owns every assertion (engine clamp state via the
# @visibleForTesting `engine` getter; real-session liveness). This script only
# drives the real OS lifecycle stimulus and reports the test's own verdict.
#
# Usage: tool/device_e2e/run_background_throttle.sh [serial]
set -uo pipefail

SERIAL="${1:-emulator-5554}"
TEST="integration_test/background_throttle_test.dart"
LOG="/tmp/ga_e2e_bg_throttle.log"
RUN_TIMEOUT=600
PKG=com.guardianangela.app
APK=build/app/outputs/flutter-apk/app-debug.apk

: "${ANDROID_HOME:=$HOME/Android/Sdk}"
export ANDROID_HOME
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"

echo "[host] serial=$SERIAL test=$TEST"

grant_all() {
  for P in ACCESS_FINE_LOCATION ACCESS_COARSE_LOCATION CALL_PHONE CAMERA \
           POST_NOTIFICATIONS READ_PHONE_NUMBERS READ_PHONE_STATE \
           RECORD_AUDIO SEND_SMS; do
    adb -s "$SERIAL" shell pm grant "$PKG" "android.permission.$P" 2>/dev/null || true
  done
  adb -s "$SERIAL" shell pm grant "$PKG" android.permission.ACCESS_BACKGROUND_LOCATION 2>/dev/null || true
}

if [ -f "$APK" ]; then
  echo "[host] pre-installing + granting ..."
  adb -s "$SERIAL" install -r "$APK" >/dev/null 2>&1 || true
  grant_all
fi
adb -s "$SERIAL" shell am force-stop "$PKG" 2>/dev/null || true

bg_app()  { echo "[host] HOME (background)"; adb -s "$SERIAL" shell input keyevent KEYCODE_HOME; }
fg_app()  { echo "[host] foreground (monkey launch)";
            adb -s "$SERIAL" shell monkey -p "$PKG" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1; }

rm -f "$LOG"
echo "[host] launching on-device test (log: $LOG) ..."
timeout "$RUN_TIMEOUT" flutter test "$TEST" -d "$SERIAL" >"$LOG" 2>&1 &
TEST_PID=$!

# This test does NOT need a runtime permission gate (a SIM session for proof A,
# and proof B's real session uses only the SIM'd infra). But grant once after
# install for good measure (real session may touch notifications).
( for _ in $(seq 1 90); do
    adb -s "$SERIAL" shell pm list packages 2>/dev/null | grep -q "$PKG" && { grant_all; break; }
    sleep 1
  done ) &

wait_for_marker() {
  local marker="$1" deadline=$(( $(date +%s) + ${2:-120} ))
  while [ "$(date +%s)" -lt "$deadline" ]; do
    if ! kill -0 "$TEST_PID" 2>/dev/null; then return 2; fi
    if grep -q "GA-E2E $marker" "$LOG" 2>/dev/null; then return 0; fi
    sleep 1
  done
  return 1
}

# ── Proof A: clamp engagement (sim) ──────────────────────────────────────────
if wait_for_marker "A-READY" 180; then
  bg_app
  if wait_for_marker "A-BACKGROUNDED" 60; then
    sleep 1
    fg_app
    wait_for_marker "A-FOREGROUNDED" 60 || echo "[host] WARN: A-FOREGROUNDED not seen."
  else
    echo "[host] WARN: A-BACKGROUNDED not seen."
    fg_app
  fi
else
  echo "[host] WARN: A-READY not seen (test may have failed early)."
fi

# ── Proof B: real-session survival ───────────────────────────────────────────
if wait_for_marker "B-READY" 120; then
  bg_app
  wait_for_marker "B-BACKGROUNDED" 30 || true
  sleep 1
  fg_app
  wait_for_marker "B-SURVIVED" 30 || echo "[host] WARN: B-SURVIVED not seen."
fi

wait "$TEST_PID"
TEST_RC=$?
echo "----------------------------------------------------------------------"
echo "[host] flutter-test exit=$TEST_RC"
echo "[host] --- tail of $LOG ---"
tail -30 "$LOG"
exit "$TEST_RC"
