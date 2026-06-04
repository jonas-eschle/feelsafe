# Guardian Angela v3 — Session Hand-off

**Snapshot:** 2026-06-04 — **Phase 9 ran its spec-coverage audit and
uncovered a systemic problem: the app's core is built + unit-tested but
largely NOT WIRED UP.** ~13 GA-blocking integration gaps — core safety
features broken or dead at runtime despite **3744 passing unit tests**.
A 6-agent completeness audit (one per feature spec doc) found them; I
spot-verified the 4 most severe myself. **A corrected-status +
remediation plan is written at `docs/rewrite/ga-wiring-remediation.md`
and is AWAITING YOUR APPROVAL.** Per your decisions this session:
**plan-first, then execute serially** (me + verifier cohorts, each fix
proven by an emulator integration test).

**NO PRODUCTION CODE CHANGED THIS SESSION.** Only two new files (the
plan doc + an emulator smoke test) — committed alongside this handoff.
**HEAD before this session:** `eed8667`. **Tests:** still **3744**
(unchanged; analyzer clean). **Branch:** `main`, **0 commits ahead of
`origin/main`** before this handoff (Phase 8 was already pushed; the
handoff snapshot that said "3 unpushed" was stale).

**The headline:** the `SessionEngine`, all 9 strategies, the data
layer, models/enums, and service *protocol impls* are genuinely solid
and tested. But **screens → controllers → services wiring is
pervasively incomplete**: methods exist and nobody calls them, settings
are stored and nothing consumes them, 3 audio assets don't exist on
disk. Unit tests pass because they test units in isolation; no test
drove a *wired* flow. This is your documented v2 postmortem
(wiring-failures) reproduced one layer up — see
[[feedback_rewrite_process]].

---

## How to resume

After `/clear`, paste:

> Continue from HANDOFF.md

**First action: read `docs/rewrite/ga-wiring-remediation.md` and get
the user to approve/adjust the plan** (they chose "plan first, then
execute"). It has: the corrected project status (§1), the full
GA-blocker inventory (§2, = tasks #8–#23), the serial execution method
(§3), 6 milestones safety-critical-first (§4), and 3 open questions for
the user (§6: approve order? Tier-F descopes? R-8 data sourcing?).

**On approval, execute milestone M0 first** (restores the app's reason
to exist — it can make noise and disarm):
1. #21 audio assets (siren/ringtone_default/countdown_warning `.ogg`
   are referenced but absent → alarm/ring/countdown are SILENT). Add
   the assets (or repoint to existing) + a CI asset-existence gate.
2. #17 fakeCall hang-up/decline/voice wiring (currently `context.pop()`
   only → fake call never disarms).
3. #19 loudAlarm gradual-volume + DND-override gating.
4. #18 disguisedReminder template rendering + confirmation types +
   `earlyCheckIn`.

Each fix: verify the gap yourself → implement (serial) → **prove with
an emulator integration test driving the wired flow** → l10n deltas →
gate suite → verifier cohort → commit. Milestones M1–M5 follow (M5 IS
the original Phase 9: INT scenarios, device e2e, finalize the
spec-coverage matrix, coverage floor).

---

## Emulator (validated — this is the new verification standard)

A headless Android emulator works here with KVM acceleration and
**collects on-device coverage including the real native services**
(closes QA gap-4). Proven by `integration_test/app_boot_smoke_test.dart`
(passes; built+installed the APK; lcov captured `call_state_service`,
`hardware_button_service`, `flash_service`, etc.).

```bash
export ANDROID_HOME=/home/jonas/Android/Sdk
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"
# Boot headless (cold). AVD 'Pixel_9_Pro' (Android 16 / API 36) pre-exists.
emulator -avd Pixel_9_Pro -no-window -no-audio -no-boot-anim \
  -gpu swiftshader_indirect -no-snapshot &
# Wait for full boot:
until [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = 1 ]; \
  do sleep 3; done; adb shell input keyevent 82
# Run an integration test WITH coverage:
flutter test integration_test/app_boot_smoke_test.dart -d emulator-5554 --coverage
```
First Gradle build ~75s; boot ~1–2 min cold. (An emulator may still be
running from this session — `adb devices` to check.)

---

## Hard rules (unchanged — apply every stage)

1. **OLD/ is INERT.** Never read/list/glob/grep/import under `OLD/`.
   Restore with `git checkout HEAD -- OLD/` if a tool dirties it.
2. **NO STUBS at GA.** All 12 S-NN categories in
   `~/.claude/plans/make-sure-that-there-typed-tulip.md §NO-STUBS` are
   CI hard fails. (The wiring gaps this audit found are exactly the
   "missing functionality" these rules exist to prevent.)
3. **NO INVENTED DEFERRALS.** "Phase X" comments only if that phase's
   plan scopes the work. Grep `lib/features/` before every commit.
4. **DO NOT guess.** `AskUserQuestion` for spec ambiguity / values
   decisions. (Used heavily this session — all decisions logged below.)
5. **Pre-alpha = break compatibility freely.** [[project_prealpha_break_compat]]
6. **Verify after EVERY fix or stage.** Analyzer + tests + (now)
   emulator integration test + grep gates. Re-engage the verifier on
   `FIX_REQUIRED`.
7. **Write/update HANDOFF.md before the session ends.**
8. **Serial default; parallel only when truly orthogonal.** The user
   reconfirmed this session: connected fixes (real-call, mode editor,
   stealth, fakeCall, reminder) stay serial; only disjoint self-
   contained fixes (audio assets, emergency-number map, iOS strings)
   may fan out. Read-only audits MAY run parallel.
9. **Co-Authored-By footer:** `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`.
10. **Pure Dart in `lib/domain/`, `lib/services/protocols/`, `lib/data/`.**
11. **lefthook re-stages auto-fixes; OLD/-safe. NEVER run `dart format .`
    or `import_sorter` REPO-WIDE** — scope to changed files. Note: the
    build regenerates `lib/l10n/l10n/app_localizations*.dart` with
    blank-line drift; `git checkout -- lib/l10n/l10n/` to discard it.
12. **Pushing to `main` needs explicit user authorization each time.**

---

## Decisions made this session (all via AskUserQuestion)

1. **Start Phase 9 now** (don't run `/ultrareview` first).
2. **Coverage:** get a real emulator running for true device coverage
   if feasible (it is) — else fall back to exclude-generated + floor 1.
3. On discovering the first 3 gaps (R-8/R-29/R-32): **fix all 3 now**
   **+ run a full spec-vs-impl completeness audit** to find others.
4. On the audit finding ~13 GA-blockers: **plan first, then execute**
   (corrected-status doc + remediation plan for review).
5. **Serial execution + verifier cohorts**; parallel only for truly
   disjoint fixes.

---

## Gap inventory (full detail in the plan doc §2 + tasks #8–#23)

**🔴 GA-blockers:** audio assets silent (#21✓); fakeCall doesn't disarm
(#17✓); disguisedReminder no template/disguise (#18); loudAlarm
gradual/DND unwired+inverted (#19); real incoming-call detection
unwired (#11); battery alert never fires + GPS never tracks (#22✓);
mode-editor can't configure steps/triggers/safety-options (#13);
SMS-contact grid missing (#14); alarm settings missing (#23); stealth
session UI + 5 granular fields unconsumed (#15). **🟠:** R-8 emergency
numbers (#10), R-32+session-end biometric (#9/#23), notification-perm
re-ask (#16), iOS warnings/channel-validation/SMS-template (#20).
**🟡 known/descope:** R-29 button (#8), background clamp (#12), system-
volume-override / AlarmManager-watchdog / call-style-ringtones /
`requireLaunchAuth` / optional feedback prompt (Tier F — confirm cuts).
(✓ = I spot-verified the absence.)

**Solid + tested (do NOT re-litigate):** engine state machine, 9
strategies, Drift/data layer, models/enums/sealed types, service
protocol impls, routing, PIN ladder, simulation swap, l10n.

---

## Spec-coverage matrix status (deferred to M5)

`test/spec_coverage_test.dart` is still the Phase-0 skeleton (assertions
commented out). This session **re-mapped all 45 R-NN** against the REAL
`docs/rewrite/spec-audit.md` definitions (the file's inline `//`
comments are DRIFTED/wrong — e.g. its "R-44 stealth aliases" is really
"notificationDisguise bool"; do not trust them). Most R-NN are COVERED;
the behavioral-gaps are exactly the items now in tasks #8–#23. The
matrix gets finalized in **M5** once features land + tests exist (can't
honestly assert "every row → passing test" while features are missing).
Pure-doc R-NN (R-19, R-39, R-43) need a DOC-ONLY treatment (sentinel
string, not a test path).

---

## Quick verification commands

```bash
dart format --output=none --set-exit-if-changed lib/ test/ integration_test/
dart run import_sorter:main --no-comments --exit-if-changed
flutter analyze --fatal-infos                                    # 0 issues
flutter test --concurrency=6                                     # 3744 pass
grep -rn 'package:flutter' lib/domain/ lib/services/protocols/ lib/data/   # empty (S-7)
grep -rnE "(Phase 8|Phase 9|Phase 10|Phase 11)" lib/features/    # 0
git status --porcelain -- OLD/                                   # empty
git checkout -- lib/l10n/l10n/   # discard generated blank-line drift if build ran
```

---

## End-of-session ritual (every session)

1. **Update HANDOFF.md** — snapshot (date, HEAD, tests, what changed,
   decisions), gap/status, next actions, emulator command.
2. **Commit HANDOFF.md** (`…-handoff: …` + Co-Authored-By footer).
3. **Tell the user the resume prompt** exactly: `Continue from HANDOFF.md`.

Don't skip it because "the session went short."

---

End of hand-off. The plan at `docs/rewrite/ga-wiring-remediation.md`
needs your approval before execution. Resume from §"How to resume".
