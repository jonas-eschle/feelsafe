/// Shared in-memory fake repositories used by feature-controller tests.
///
/// Each fake subclasses the real repository via `forTesting()` so
/// every method can be overridden without touching Drift or the DAOs.
library;

import 'package:guardianangela/data/repositories/battery_alert_repository.dart';
import 'package:guardianangela/data/repositories/contacts_repository.dart';
import 'package:guardianangela/data/repositories/distress_chains_repository.dart';
import 'package:guardianangela/data/repositories/modes_repository.dart';
import 'package:guardianangela/data/repositories/session_logs_repository.dart';
import 'package:guardianangela/data/repositories/settings_repository.dart';
import 'package:guardianangela/data/repositories/templates_repository.dart';
import 'package:guardianangela/data/repositories/user_profile_repository.dart';
import 'package:guardianangela/domain/models/models.dart';

/// In-memory fake of [ModesRepository].
class FakeModesRepository extends ModesRepository {
  /// Creates a fake seeded with [initial].
  FakeModesRepository([List<SessionMode> initial = const []])
    : _items = List<SessionMode>.of(initial),
      super.forTesting();
  final List<SessionMode> _items;

  /// Errors thrown by the next mutator call (one-shot).
  Object? throwOnSave;

  @override
  Future<List<SessionMode>> getAll() async => List<SessionMode>.of(_items);

  @override
  Future<SessionMode?> getById(String id) async {
    for (final m in _items) {
      if (m.id == id) return m;
    }
    return null;
  }

  @override
  Future<void> save(SessionMode value) async {
    if (throwOnSave != null) {
      final err = throwOnSave!;
      throwOnSave = null;
      throw err;
    }
    _items.removeWhere((m) => m.id == value.id);
    _items.add(value);
  }

  @override
  Future<void> saveAll(List<SessionMode> values) async {
    _items.clear();
    _items.addAll(values);
  }

  @override
  Future<void> delete(String id) async =>
      _items.removeWhere((m) => m.id == id);

  @override
  Future<void> deleteAll() async => _items.clear();
}

/// In-memory fake of [ContactsRepository].
class FakeContactsRepository extends ContactsRepository {
  /// Creates a fake seeded with [initial].
  FakeContactsRepository([List<EmergencyContact> initial = const []])
    : _items = List<EmergencyContact>.of(initial),
      super.forTesting();
  final List<EmergencyContact> _items;

  @override
  Future<List<EmergencyContact>> getAll() async =>
      List<EmergencyContact>.of(_items);

  @override
  Future<EmergencyContact?> getById(String id) async {
    for (final c in _items) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  Future<void> save(EmergencyContact value) async {
    _items.removeWhere((c) => c.id == value.id);
    _items.add(value);
  }

  @override
  Future<void> delete(String id) async =>
      _items.removeWhere((c) => c.id == id);

  @override
  Future<void> deleteAll() async => _items.clear();
}

/// In-memory fake of [SettingsRepository].
class FakeSettingsRepository extends SettingsRepository {
  /// Creates a fake seeded with [initial] (null means unset).
  FakeSettingsRepository([AppSettings? initial])
    : _stored = initial,
      super.forTesting();
  AppSettings? _stored;

  /// The last value persisted via [save].
  AppSettings? get stored => _stored;

  @override
  Future<AppSettings?> get() async => _stored;

  @override
  Future<void> save(AppSettings value) async => _stored = value;
}

/// In-memory fake of [DistressChainsRepository].
class FakeDistressChainsRepository extends DistressChainsRepository {
  /// Creates a fake seeded with [initial].
  FakeDistressChainsRepository([List<DistressChain> initial = const []])
    : _items = List<DistressChain>.of(initial),
      super.forTesting();
  final List<DistressChain> _items;

  @override
  Future<List<DistressChain>> getAll() async => List<DistressChain>.of(_items);

  @override
  Future<DistressChain?> getById(String id) async {
    for (final c in _items) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  Future<void> save(DistressChain value) async {
    _items.removeWhere((c) => c.id == value.id);
    _items.add(value);
  }

  @override
  Future<void> delete(String id) async =>
      _items.removeWhere((c) => c.id == id);

  @override
  Future<void> deleteAll() async => _items.clear();
}

/// In-memory fake of [TemplatesRepository].
class FakeTemplatesRepository extends TemplatesRepository {
  /// Creates a fake seeded with [initial].
  FakeTemplatesRepository([List<ReminderTemplate> initial = const []])
    : _items = List<ReminderTemplate>.of(initial),
      super.forTesting();
  final List<ReminderTemplate> _items;

  @override
  Future<List<ReminderTemplate>> getAll() async =>
      List<ReminderTemplate>.of(_items);

  @override
  Future<List<ReminderTemplate>> getAllGlobal() async =>
      _items.where((t) => t.isGlobal).toList();

  @override
  Future<ReminderTemplate?> getById(String id) async {
    for (final t in _items) {
      if (t.id == id) return t;
    }
    return null;
  }

  @override
  Future<void> save(ReminderTemplate value) async {
    _items.removeWhere((t) => t.id == value.id);
    _items.add(value);
  }

  @override
  Future<void> delete(String id) async =>
      _items.removeWhere((t) => t.id == id);

  @override
  Future<void> deleteAll() async => _items.clear();
}

/// In-memory fake of [UserProfileRepository].
class FakeUserProfileRepository extends UserProfileRepository {
  /// Creates a fake seeded with [initial].
  FakeUserProfileRepository([UserProfile? initial])
    : _stored = initial,
      super.forTesting();
  UserProfile? _stored;

  /// The last persisted value.
  UserProfile? get stored => _stored;

  @override
  Future<UserProfile?> get() async => _stored;

  @override
  Future<void> save(UserProfile value) async => _stored = value;
}

/// In-memory fake of [BatteryAlertRepository].
class FakeBatteryAlertRepository extends BatteryAlertRepository {
  /// Creates a fake seeded with [initial].
  FakeBatteryAlertRepository([BatteryAlertConfig? initial])
    : _stored = initial,
      super.forTesting();
  BatteryAlertConfig? _stored;

  /// The last persisted value.
  BatteryAlertConfig? get stored => _stored;

  @override
  Future<BatteryAlertConfig?> get() async => _stored;

  @override
  Future<void> save(BatteryAlertConfig value) async => _stored = value;
}

/// In-memory fake of [SessionLogsRepository].
class FakeSessionLogsRepository extends SessionLogsRepository {
  /// Creates a fake seeded with [initial].
  FakeSessionLogsRepository([List<SessionLog> initial = const []])
    : _items = List<SessionLog>.of(initial),
      super.forTesting();
  final List<SessionLog> _items;

  @override
  Future<List<SessionLog>> getAll() async => List<SessionLog>.of(_items);

  @override
  Future<SessionLog?> getById(String id) async {
    for (final l in _items) {
      if (l.id == id) return l;
    }
    return null;
  }

  @override
  Future<void> save(SessionLog value) async {
    _items.removeWhere((l) => l.id == value.id);
    _items.add(value);
  }

  @override
  Future<void> delete(String id) async =>
      _items.removeWhere((l) => l.id == id);

  @override
  Future<void> deleteAll() async => _items.clear();
}
