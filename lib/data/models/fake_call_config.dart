import 'package:hive/hive.dart';

part 'fake_call_config.g.dart';

@HiveType(typeId: 6)
class FakeCallConfig extends HiveObject {
  @HiveField(0)
  String callerName;

  @HiveField(1)
  String? photoPath;

  @HiveField(2)
  String? voiceRecordingPath;

  @HiveField(3)
  int ringDurationSeconds;

  FakeCallConfig({
    this.callerName = 'Mom',
    this.photoPath,
    this.voiceRecordingPath,
    this.ringDurationSeconds = 30,
  });

  Duration get ringDuration => Duration(seconds: ringDurationSeconds);

  FakeCallConfig copyWith({
    String? callerName,
    String? photoPath,
    String? voiceRecordingPath,
    int? ringDurationSeconds,
  }) {
    return FakeCallConfig(
      callerName: callerName ?? this.callerName,
      photoPath: photoPath ?? this.photoPath,
      voiceRecordingPath: voiceRecordingPath ?? this.voiceRecordingPath,
      ringDurationSeconds: ringDurationSeconds ?? this.ringDurationSeconds,
    );
  }
}
