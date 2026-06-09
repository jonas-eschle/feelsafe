#!/usr/bin/env bash
# Host runner for the C4 #11 device-e2e proof (real incoming-call pause/resume).
#
# Coordination: this runs the on-device integration test in the background and
# tails the device logcat for the test's `GA-E2E` markers, firing the matching
# `adb emu gsm` commands at the marker boundaries. The on-device test owns every
# assertion (against the REAL SessionController/SessionEngine state); this script
# only injects the telephony stimulus and reports the test's own pass/fail.
#
#   GA-E2E READY-FOR-CALL   → adb emu gsm call <num>     (deliver incoming call)
#   GA-E2E PAUSE-OBSERVED   → adb emu gsm cancel <num>   (end the call)
#   GA-E2E RESUME-OBSERVED / DONE  (informational)
#
# Usage: tool/device_e2e/run_real_call_pause.sh [serial]
# Wraps the flutter run in `timeout` (a hung emulator test won't self-kill).
set -uo pipefail

SERIAL="${1:-emulator-5554}"
NUM="5551234567"
TEST="integration_test/real_call_pause_test.dart"
LOG="/tmp/ga_e2e_real_call.log"
RUN_TIMEOUT=600   # seconds — generous for the first Gradle build + the run

: "${ANDROID_HOME:=$HOME/Android/Sdk}"
export ANDROID_HOME
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"

echo "[host] serial=$SERIAL test=$TEST"

PKG=com.guardianangela.app
APK=build/app/outputs/flutter-apk/app-debug.apk

# A REAL session on a real device touches several runtime-permission-gated
# services (telephony, location, notifications, FG service). On a HEADLESS
# emulator an ungranted permission pops a GrantPermissionsActivity dialog that
# blocks the UI and HANGS the test. So we PRE-INSTALL the debug APK and grant
# every dangerous permission UP FRONT; grants persist across the reinstall that
# `flutter test` performs on the same signing key (verified), so the test body
# never hits a dialog. READ_PHONE_STATE in particular MUST be granted before the
# native CallStateChannel's listener starts, or it emits `permissionDenied` and
# the call is never delivered.
grant_all() {
  for P in ACCESS_FINE_LOCATION ACCESS_COARSE_LOCATION CALL_PHONE CAMERA \
           POST_NOTIFICATIONS READ_PHONE_NUMBERS READ_PHONE_STATE \
           RECORD_AUDIO SEND_SMS; do
    adb -s "$SERIAL" shell pm grant "$PKG" "android.permission.$P" 2>/dev/null || true
  done
  adb -s "$SERIAL" shell pm grant "$PKG" android.permission.ACCESS_BACKGROUND_LOCATION 2>/dev/null || true
}

if [ -f "$APK" ]; then
  echo "[host] pre-installing $APK + granting permissions ..."
  adb -s "$SERIAL" install -r "$APK" >/dev/null 2>&1 || true
  grant_all
else
  echo "[host] NOTE: $APK not built yet — building via flutter test, then granting."
fi

# Make sure no stale call is in progress from a prior aborted run. The native
# listener only fires on a STATE TRANSITION (idle→ringing), so if a leftover
# call keeps telephony in RINGING when the listener registers, NO event fires
# and the pause never happens. Cancel and WAIT until telephony is idle.
adb -s "$SERIAL" shell am force-stop "$PKG" 2>/dev/null || true
for _ in $(seq 1 10); do
  adb -s "$SERIAL" emu gsm cancel "$NUM" >/dev/null 2>&1 || true
  cs=$(adb -s "$SERIAL" shell dumpsys telephony.registry 2>/dev/null | grep -m1 "mCallState=" | grep -oE '[0-9]+')
  [ "$cs" = "0" ] && break
  sleep 1
done
echo "[host] telephony idle (mCallState=${cs:-?}) before run."

# Clear logcat so our marker poll only sees this run.
adb -s "$SERIAL" logcat -c 2>/dev/null || true

rm -f "$LOG"
echo "[host] launching on-device test (log: $LOG) ..."
timeout "$RUN_TIMEOUT" flutter test "$TEST" -d "$SERIAL" >"$LOG" 2>&1 &
TEST_PID=$!

# Markers are emitted via `debugPrint`, which on `flutter test` routes to the
# HOST test stdout (this $LOG), NOT Android logcat. So poll the log file.
wait_for_marker() {
  local marker="$1" deadline=$(( $(date +%s) + ${2:-120} ))
  while [ "$(date +%s)" -lt "$deadline" ]; do
    if ! kill -0 "$TEST_PID" 2>/dev/null; then return 2; fi  # test exited early
    if grep -q "GA-E2E $marker" "$LOG" 2>/dev/null; then return 0; fi
    sleep 1
  done
  return 1
}

STEP_RC=0

# `flutter test` reinstalls the app (wiping any pre-grant), then the Dart test
# gates startSession on READ_PHONE_STATE via the AWAITING-PHONE-GRANT marker.
# Grant in a tight loop from that marker until the session is ready, so the
# grant deterministically lands before the native listener starts.
if wait_for_marker "AWAITING-PHONE-GRANT" 180; then
  echo "[host] AWAITING-PHONE-GRANT seen → granting in a loop until READY ..."
  ( while kill -0 "$TEST_PID" 2>/dev/null; do
      grant_all
      grep -q "GA-E2E READY-FOR-CALL" "$LOG" 2>/dev/null && break
      sleep 0.5
    done ) &
else
  echo "[host] WARN: AWAITING-PHONE-GRANT not seen — granting once defensively."
  grant_all
fi

if wait_for_marker "READY-FOR-CALL" 180; then
  echo "[host] READY-FOR-CALL seen → firing: adb emu gsm call $NUM"
  adb -s "$SERIAL" emu gsm call "$NUM"
  if wait_for_marker "PAUSE-OBSERVED" 90; then
    echo "[host] PAUSE-OBSERVED seen → firing: adb emu gsm cancel $NUM"
    adb -s "$SERIAL" emu gsm cancel "$NUM"
    if wait_for_marker "RESUME-OBSERVED" 90; then
      echo "[host] RESUME-OBSERVED seen — coordination complete."
    else
      echo "[host] WARN: RESUME-OBSERVED not seen (test will assert)."
      STEP_RC=1
    fi
  else
    echo "[host] WARN: PAUSE-OBSERVED not seen — cancelling call defensively."
    adb -s "$SERIAL" emu gsm cancel "$NUM" >/dev/null 2>&1 || true
    STEP_RC=1
  fi
else
  rc=$?
  [ "$rc" = 2 ] && echo "[host] test exited before READY-FOR-CALL." \
                || echo "[host] timed out waiting for READY-FOR-CALL."
  adb -s "$SERIAL" emu gsm cancel "$NUM" >/dev/null 2>&1 || true
  STEP_RC=1
fi

# Always reap the test process and report ITS verdict (the source of truth).
wait "$TEST_PID"
TEST_RC=$?

echo "----------------------------------------------------------------------"
echo "[host] flutter-test exit=$TEST_RC  coordination_rc=$STEP_RC"
echo "[host] --- tail of $LOG ---"
tail -25 "$LOG"
# Defensive: leave telephony idle.
adb -s "$SERIAL" emu gsm cancel "$NUM" >/dev/null 2>&1 || true

# The test's own exit is authoritative. coordination_rc only matters if the test
# somehow passed without the stimulus (impossible — pollUntil would time out).
exit "$TEST_RC"
