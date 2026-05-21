# Guardian Angela

Personal safety app with dead man's switch — Flutter / Android + iOS.

**Pre-alpha. v3 rewrite in progress. See `docs/rewrite/v3-plan.md`.**

---

## Quick start

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze --fatal-infos
flutter test
flutter run
```

Build release APK:

```bash
flutter build apk --release
```

---

## Architecture

See `docs/spec/00-overview.md` for the canonical architecture.

Short summary:

- **State:** Riverpod 3 (Notifier)
- **Navigation:** GoRouter
- **Storage:** Drift + sqlite3mc (encrypted at rest)
- **Engine:** Pure-Dart state machine (`lib/domain/engine/`)
- **Services:** Real/Simulation triplet pattern
  (`lib/services/service_providers.dart` is the single owner)
- **Localization:** 14 languages (`lib/l10n/l10n/`)

---

## Reference: v2 implementation

`OLD/` is a read-only archive of the v2 implementation. It is not
built, not linted, and not tested. See `docs/rewrite/v3-plan.md §5`
for the one-time extractions that were permitted during Phase 0.

Do not read or import from `OLD/` for any purpose. If behaviour is
unclear, read the spec (`docs/spec/`).

The v2 git history is preserved at the `v2-archive` tag.

---

## Spec

Full specification:

- `docs/spec/00-overview.md` — Architecture overview + invariants
- `docs/spec/01-chain-engine.md` — SessionEngine state machine
- `docs/spec/02-event-types.md` — 9 escalation step types
- `docs/spec/03-data-models.md` — All models, enums, persistence
- `docs/spec/04-screens-navigation.md` — 24 screens + routing
- `docs/spec/05-services.md` — Services layer + native channels
- `docs/spec/06-settings.md` — Settings + security + defaults
- `docs/spec/07-test-plan.md` — Test plan (all test IDs)
- `docs/spec/08-decisions-consolidated.md` — Decision log
- `docs/spec/09-glossary.md` — Terms
- `docs/spec/10-platform-matrix.md` — Per-platform capability matrix
- `docs/spec/11-deferred-enhancements.md` — All DE-N promoted or
  deleted; nothing remains deferred (per D15)
