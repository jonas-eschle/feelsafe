/// Unit tests for [HistoryRetentionController] against a recording fake
/// [AppSettingsRepository].
///
/// Plain `test()` + bare [ProviderContainer] (no widget pump) so
/// `ref.invalidateSelf()` re-runs `build()` without leaking timers. The
/// recording fake pins exactly what is persisted: each setter must save
/// a copy of the CURRENT settings with only its own field changed —
/// clobbering the sibling retention value would silently rewrite the
/// user's purge windows.
///
/// Spec ref: `docs/spec/06-settings.md §History & Retention Screen`.
library;

import 'dart:io';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/features/history_retention/history_retention_controller.dart';
import 'package:guardianangela/services/service_providers.dart';

class _FakeAppSettingsRepository extends AppSettingsRepository {
  _FakeAppSettingsRepository(this._current)
    : super(
        keyProvider: () async => '00' * 32,
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('history_retention_ctl_'),
      );

  AppSettings _current;

  /// Every value passed to [save], in order.
  final List<AppSettings> saved = <AppSettings>[];

  @override
  Future<AppSettings> load() async => _current;

  @override
  Future<void> save(AppSettings value) async {
    _current = value;
    saved.add(value);
  }
}

void main() {
  late _FakeAppSettingsRepository settingsRepo;
  late ProviderContainer container;

  setUp(() {
    settingsRepo = _FakeAppSettingsRepository(
      const AppSettings(sessionLogRetentionDays: 90, trashRetentionDays: 14),
    );
    container = ProviderContainer(
      overrides: <Override>[
        appSettingsRepositoryProvider.overrideWithValue(settingsRepo),
      ],
    );
  });

  tearDown(() => container.dispose());

  Future<HistoryRetentionState> state() =>
      container.read(historyRetentionControllerProvider.future);

  group('HistoryRetentionController.build', () {
    test('exposes both retention windows from settings', () async {
      final HistoryRetentionState s = await state();

      check(s.sessionLogRetentionDays).equals(90);
      check(s.trashRetentionDays).equals(14);
    });
  });

  group('HistoryRetentionController.setSessionLogRetention', () {
    test('persists the new value, keeps trash window, refreshes', () async {
      final controller = container.read(
        historyRetentionControllerProvider.notifier,
      );
      await state();

      await controller.setSessionLogRetention(30);

      check(settingsRepo.saved.length).equals(1);
      check(settingsRepo.saved.single.sessionLogRetentionDays).equals(30);
      // The sibling window must NOT be clobbered back to its default.
      check(settingsRepo.saved.single.trashRetentionDays).equals(14);
      final HistoryRetentionState s = await state();
      check(s.sessionLogRetentionDays).equals(30);
      check(s.trashRetentionDays).equals(14);
    });
  });

  group('HistoryRetentionController.setTrashRetention', () {
    test('persists the new value, keeps log window, refreshes', () async {
      final controller = container.read(
        historyRetentionControllerProvider.notifier,
      );
      await state();

      await controller.setTrashRetention(3);

      check(settingsRepo.saved.length).equals(1);
      check(settingsRepo.saved.single.trashRetentionDays).equals(3);
      check(settingsRepo.saved.single.sessionLogRetentionDays).equals(90);
      final HistoryRetentionState s = await state();
      check(s.trashRetentionDays).equals(3);
      check(s.sessionLogRetentionDays).equals(90);
    });
  });
}
