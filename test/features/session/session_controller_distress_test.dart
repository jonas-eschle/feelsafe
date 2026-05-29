/// Tests for [SessionController.startDistressSession] — the cold-start distress
/// entry used by the App-lock launch gate (spec 06 §App PIN / §Duress PIN).
///
/// Focuses on the new resolution + fail-loud logic: when no default distress
/// mode is configured, or the referenced mode is missing, the controller must
/// surface an error rather than silently doing nothing (global "fail loud"
/// policy). The happy path (resolve → startSession → confirmDistress) reuses
/// the independently-tested startSession / confirmDistress / engine paths and
/// is exercised end-to-end by the launch-gate widget test.
library;

import 'dart:io';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/models/app_defaults.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/services/service_providers.dart';

class _FakeAppSettingsRepository extends AppSettingsRepository {
  _FakeAppSettingsRepository(this._current)
    : super(
        keyProvider: () async =>
            '0102030405060708090a0b0c0d0e0f'
            '101112131415161718191a1b1c1d1e1f20',
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('session_ctl_test_'),
      );

  final AppSettings _current;

  @override
  Future<AppSettings> load() async => _current;
}

ProviderContainer _container(AppSettings settings, GuardianAngelaDatabase db) {
  final container = ProviderContainer(
    overrides: [
      appSettingsRepositoryProvider.overrideWithValue(
        _FakeAppSettingsRepository(settings),
      ),
      databaseProvider.overrideWith((ref) async => db),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  late GuardianAngelaDatabase db;

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
  });

  tearDown(() async {
    await db.close();
  });

  test('fails loud when no default distress mode is configured', () async {
    final container = _container(const AppSettings(), db);
    await container.read(sessionControllerProvider.future);
    await container
        .read(sessionControllerProvider.notifier)
        .startDistressSession(reason: EndReason.duressPin);
    final state = container.read(sessionControllerProvider).value;
    check(state?.lastError).isNotNull();
  });

  test('fails loud when the default distress mode id is missing', () async {
    final settings = const AppSettings().copyWith(
      defaults: const AppDefaults(defaultDistressModeId: 'does-not-exist'),
    );
    final container = _container(settings, db);
    await container.read(sessionControllerProvider.future);
    await container
        .read(sessionControllerProvider.notifier)
        .startDistressSession(reason: EndReason.duressPin);
    final state = container.read(sessionControllerProvider).value;
    check(state?.lastError).isNotNull();
    check(state!.lastError!).contains('does-not-exist');
  });

  test('does not start an engine on the fail-loud path', () async {
    final container = _container(const AppSettings(), db);
    await container.read(sessionControllerProvider.future);
    final notifier = container.read(sessionControllerProvider.notifier);
    await notifier.startDistressSession(reason: EndReason.duressPin);
    // No engine spun up — the run never reached startSession.
    check(notifier.engine).isNull();
  });
}
