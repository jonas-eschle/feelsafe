# Test Fakes for Event Strategies

`_test_fakes.dart` is the single shared fake library for the 9 strategy
test files in this directory. Every strategy test imports it to get fake
service implementations and the `buildServices()` factory.

---

## Fake contract

Every fake service (e.g. `FakeAudioService`, `FakeVibrationService`) has:

- A `calls` field: `List<Map<String, Object?>>`. Every method call appends
  one entry. The entry always has a `'method'` key (the method name as a
  string) plus one key per named / positional parameter.

- Default return values: `Future<void>.value()` for void futures,
  `null` for `Future<String?>` return types, `true` for `Future<bool>`.

No fake throws; they are all unconditionally successful by default. To
inject failures, use the `sendHook` parameter on `FakeMessagingService`.

---

## Injecting custom behaviour

### `FakeMessagingService.sendHook`

Pass a callback to intercept `sendMessage` calls:

```dart
final messaging = FakeMessagingService(
  sendHook: ({required contact, required message, isSimulation = false}) async {
    throw Exception('SMS delivery failed');
  },
);
```

### `FakeLocationService` constructor params

```dart
FakeLocationService(
  lastLocationUrl: null,               // simulate no GPS fix
  lastLocationDescription: 'Last known location at 2026-05-22T10:00:00Z',
)
```

---

## `buildServices()` factory

`buildServices()` returns a fully wired `EventServices` with all fakes.
Pass only the fields relevant to the test; everything else defaults.

```dart
final messaging = FakeMessagingService();
final services = buildServices(
  messaging: messaging,
  contacts: [someContact],
  userName: 'Alice',
);
```

### Default values

| Field | Default |
|---|---|
| `isSimulation` | `false` |
| `contacts` | `[]` |
| `lastLocationUrl` | `'https://maps.google.com/?q=0.0,0.0'` |
| `lastLocationDescription` | `null` |
| All service params | fresh fake instance |

---

## Asserting on `calls`

```dart
// Assert exactly one sendMessage was dispatched:
expect(messaging.calls, hasLength(1));
expect(messaging.calls.first['method'], equals('sendMessage'));
expect(messaging.calls.first['isSimulation'], isFalse);

// Assert the contact name:
final contact = messaging.calls.first['contact'] as EmergencyContact;
expect(contact.name, equals('Alice'));
```

---

## Sim-guard tests

To test that `executeReal` is a no-op under simulation:

```dart
final audio = FakeAudioService();
final services = buildServices(audio: audio, isSimulation: true);
await LoudAlarmStrategy().executeReal(someStep, services);
expect(audio.calls, isEmpty);  // sim_blocked — nothing fired
```
