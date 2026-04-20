# Guardian Angela — Wiring Map

Checked-in artifact tracking every `field → provider → service → side-effect` chain in the app. A test at `test/wiring/wiring_map_coverage_test.dart` parses this table and verifies every row maps to a real provider binding. Any row missing a provider, or any provider missing a row, fails CI.

Closes failure modes L8 (wiring-map drift) and L11 (implicit wiring) per `docs/rebuild-strategy.md` §2.

## Schema

Each row in the table below documents one wiring chain:

| Field | Provider | Service | Side-effect | Closes |
|-------|----------|---------|-------------|--------|
| `<model.field>` | `<riverpodProvider>` | `<ServiceProtocol.method>` | `<real-world effect>` | `L<n>` or `—` |

## Rules

1. **One row per persisted field that leads to a real-world side-effect.** Pure-data fields (e.g., `name`) don't need a row. A field like `AppSettings.emergencyCallNumber` that ends up as a phone call needs a row.
2. **Provider column must cite a real Riverpod provider** that lives in `lib/services/service_providers.dart` or `lib/data/repositories/repository_providers.dart`.
3. **Service column cites a protocol + method**, e.g., `PhoneServiceProtocol.callEmergency`. Never a concrete class.
4. **Side-effect column is human-readable** — "dials emergency number", "sends SMS with location", "shows notification".
5. **Closes column** links to the failure mode this wiring prevents (L1–L14) or `—` if not safety-critical.

## Example row (template — not yet active)

| `AppSettings.emergencyCallNumber` | `settingsControllerProvider` | `PhoneServiceProtocol.callEmergency(number, {isSimulation})` | Dials configured emergency number (default `112`) on `callEmergency` step | L1 |

## Table

(Populated from Phase 11 onward as controllers are filled. Phase 0/1 starts with an empty table.)

| Field | Provider | Service | Side-effect | Closes |
|-------|----------|---------|-------------|--------|

*(empty)*
