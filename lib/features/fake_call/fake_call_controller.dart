import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/fake_call_config.dart';
import '../../data/repositories/settings_repository.dart';
import '../settings/settings_controller.dart';

final fakeCallConfigProvider =
    AsyncNotifierProvider<FakeCallConfigController, FakeCallConfig>(
  FakeCallConfigController.new,
);

class FakeCallConfigController extends AsyncNotifier<FakeCallConfig> {
  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  @override
  Future<FakeCallConfig> build() => _repo.getFakeCallConfig();

  Future<void> updateConfig({
    String? callerName,
    String? photoPath,
    String? voiceRecordingPath,
    int? ringDurationSeconds,
  }) async {
    final current = await future;
    final updated = current.copyWith(
      callerName: callerName,
      photoPath: photoPath,
      voiceRecordingPath: voiceRecordingPath,
      ringDurationSeconds: ringDurationSeconds,
    );
    await _repo.saveFakeCallConfig(updated);
    state = AsyncData(updated);
  }

  Future<void> clearPhoto() async {
    final current = await future;
    final updated = FakeCallConfig(
      callerName: current.callerName,
      photoPath: null,
      voiceRecordingPath: current.voiceRecordingPath,
      ringDurationSeconds: current.ringDurationSeconds,
    );
    await _repo.saveFakeCallConfig(updated);
    state = AsyncData(updated);
  }

  Future<void> clearVoiceRecording() async {
    final current = await future;
    final updated = FakeCallConfig(
      callerName: current.callerName,
      photoPath: current.photoPath,
      voiceRecordingPath: null,
      ringDurationSeconds: current.ringDurationSeconds,
    );
    await _repo.saveFakeCallConfig(updated);
    state = AsyncData(updated);
  }
}
