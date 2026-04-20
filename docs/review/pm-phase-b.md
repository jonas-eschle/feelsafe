# Phase B (Hive Persistence) -- Issues Only

## BUG: Encryption key round-trip is lossy
`HiveBoxes.init()` stores the 32-byte key via `String.fromCharCodes` and
reads it back via `existingKey.codeUnits.take(32)`. For bytes > 127,
`FlutterSecureStorage` may UTF-8 encode then decode, producing different
`codeUnits`. Use base64 encode/decode instead of `fromCharCodes`/`codeUnits`.

## BUG: `reorderContacts` does not persist
`ContactsController.reorderContacts()` updates in-memory `state` but never
writes the new order to the repo. All sort orders are lost on app restart.

## MISSING: No repos for 5 persistent models
`repository_providers.dart` covers 4 models (settings, profile, modes,
contacts). Missing providers for: `ReminderTemplate`, `EventDefaults`,
`SessionLog`, `DuressChainConfig`, `BatteryAlertConfig`, `WrongPinChainConfig`.
Box names exist in `BoxNames` but no providers or controllers use them.

## DEAD CODE: `SingletonRepository` and `ListRepository`
`singleton_repository.dart` and `list_repository.dart` are unused -- all
providers use the `Json*` variants. Should be deleted.

## SILENT SWALLOW: All controllers catch-and-ignore errors
Every `_loadFromRepo()` and `_save()` uses `catch (_) {}` with zero logging.
Good for test fallback, but production persistence failures will be invisible.
Add `log()` from `dart:developer` inside catch blocks.

## RACE: Synchronous `build()` returns defaults, async load overwrites later
All 4 controllers call async `_loadFromRepo()` fire-and-forget from `build()`.
Between `build()` returning defaults and the Future completing, any mutation
triggers `_save()` and overwrites persisted data with defaults. Low
probability but possible on slow storage/fast user interaction.

## MINOR: Modes seed generates new UUIDs every call
`seedWalkMode()`/`seedDateMode()` call `_uuid.v4()` for each `ChainStep`,
so every invocation produces different IDs. The `ModesController.build()`
returns `[seedWalkMode(), seedDateMode()]` as the synchronous default, then
`_loadFromRepo()` may save different-ID copies. Harmless now (IDs compared
by mode.id not step.id) but fragile.

## Checklist summary
| Check | Status |
|---|---|
| 4 controllers use repo providers | PASS |
| .catchError for test fallback | PASS (but no logging) |
| main.dart calls HiveBoxes.init() | PASS |
| Modes seeds on first launch | PASS |
| Json repos correct | PASS |
| Repo providers for all models | FAIL -- 5 models missing |
