/// Unit tests for [RingtonePicker] (Tier-F F3 — user-supplied fake-call
/// ringtone). Proves the pick → copy-into-app-storage → stored-path chain
/// using the injectable `opener` / `docsDirProvider` / `uuidGenerator` seams,
/// so the flow is host-testable without platform channels.
library;

import 'dart:io';

import 'package:checks/checks.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:guardianangela/core/utils/ringtone_picker.dart';

void main() {
  late Directory tmp;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('ga_ringtone_picker_');
  });

  tearDown(() {
    if (tmp.existsSync()) {
      tmp.deleteSync(recursive: true);
    }
  });

  /// Writes [bytes] to a source file named [name] under a `source/` subdir and
  /// returns its path (simulating a file the user browses to).
  String writeSource(String name, List<int> bytes) {
    final dir = Directory(p.join(tmp.path, 'source'))
      ..createSync(recursive: true);
    final f = File(p.join(dir.path, name))..writeAsBytesSync(bytes);
    return f.path;
  }

  /// Builds a [RingtonePicker] whose docs dir is the temp dir and whose UUID
  /// is fixed, with [openerResult] returned from the picker.
  RingtonePicker buildPicker({
    required XFile? Function() openerResult,
    String uuid = 'fixed-uuid',
    List<XTypeGroup>? captureGroups,
  }) => RingtonePicker(
    opener: (groups) async {
      captureGroups?.addAll(groups);
      return openerResult();
    },
    docsDirProvider: () async => tmp,
    uuidGenerator: () => uuid,
  );

  group('pickAndStoreRingtone', () {
    test('returns null when the user cancels the picker', () async {
      final picker = buildPicker(openerResult: () => null);
      final result = await picker.pickAndStoreRingtone();
      check(result).isNull();
    });

    test('copies the picked file into <docs>/ringtones/<uuid>.<ext> and '
        'returns the stored path', () async {
      final src = writeSource('mysong.mp3', const [1, 2, 3, 4]);
      final picker = buildPicker(
        openerResult: () => XFile(src),
        uuid: 'abc123',
      );

      final result = await picker.pickAndStoreRingtone();

      check(result).isNotNull();
      final stored = result!;
      check(p.basename(stored)).equals('abc123.mp3');
      check(p.dirname(stored)).equals(p.join(tmp.path, 'ringtones'));
      // The stored file exists and has the source bytes (a real copy).
      check(File(stored).existsSync()).isTrue();
      check(File(stored).readAsBytesSync()).deepEquals(const [1, 2, 3, 4]);
    });

    test('the stored copy survives deletion of the source file '
        '(the reference is durable)', () async {
      final src = writeSource('clip.m4a', const [9, 8, 7]);
      final picker = buildPicker(openerResult: () => XFile(src));

      final stored = (await picker.pickAndStoreRingtone())!;
      // Delete the original source — the imported copy must remain.
      File(src).deleteSync();

      check(File(stored).existsSync()).isTrue();
      check(File(stored).readAsBytesSync()).deepEquals(const [9, 8, 7]);
    });

    test('preserves the source extension (m4a)', () async {
      final src = writeSource('voice.m4a', const [1]);
      final picker = buildPicker(openerResult: () => XFile(src));
      final stored = (await picker.pickAndStoreRingtone())!;
      check(p.extension(stored)).equals('.m4a');
    });

    test('defaults to .mp3 when the source has no extension', () async {
      final src = writeSource('noext', const [1]);
      final picker = buildPicker(openerResult: () => XFile(src));
      final stored = (await picker.pickAndStoreRingtone())!;
      check(p.extension(stored)).equals('.mp3');
    });

    test('creates the ringtones/ subdir when absent', () async {
      check(Directory(p.join(tmp.path, 'ringtones')).existsSync()).isFalse();
      final src = writeSource('a.wav', const [1]);
      final picker = buildPicker(openerResult: () => XFile(src));
      await picker.pickAndStoreRingtone();
      check(Directory(p.join(tmp.path, 'ringtones')).existsSync()).isTrue();
    });

    test(
      'offers an audio type group filtered to the ringtone extensions',
      () async {
        final groups = <XTypeGroup>[];
        final src = writeSource('a.wav', const [1]);
        final picker = buildPicker(
          openerResult: () => XFile(src),
          captureGroups: groups,
        );
        await picker.pickAndStoreRingtone();
        check(groups).length.equals(1);
        check(groups.single.extensions).isNotNull();
        check(groups.single.extensions!).contains('mp3');
        check(groups.single.extensions!).contains('m4a');
      },
    );

    test('distinct UUIDs yield distinct stored paths', () async {
      final src = writeSource('a.mp3', const [1]);
      final stored1 = (await buildPicker(
        openerResult: () => XFile(src),
        uuid: 'u1',
      ).pickAndStoreRingtone())!;
      final stored2 = (await buildPicker(
        openerResult: () => XFile(src),
        uuid: 'u2',
      ).pickAndStoreRingtone())!;
      check(stored1).not((it) => it.equals(stored2));
    });
  });
}
