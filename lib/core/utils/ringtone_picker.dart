import 'dart:developer';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Audio file extensions offered in the ringtone import picker.
///
/// Covers the common phone-ringtone container formats that `just_audio`
/// decodes on both Android and iOS. The native document picker filters the
/// browse list to these; the user supplies their OWN audio so there is no
/// licensing concern (Tier-F F3).
const List<String> kRingtoneExtensions = <String>[
  'mp3',
  'm4a',
  'aac',
  'wav',
  'ogg',
  'flac',
];

/// Imports a user-supplied fake-call ringtone via the native file picker and
/// copies it into app-internal storage (Tier-F F3).
///
/// The owner reframed the original per-`CallStyle` bundled-ringtone concept to
/// "let the user supply their own ringtone audio", which sidesteps the
/// trademark/licensing risk of bundling per-call-style assets.
///
/// [pickAndStoreRingtone] returns the **app-internal** path of the stored
/// copy, or `null` if the user cancelled the picker. A picked file's path is
/// transient (the OS may hand back a cache/content URI that is later cleared,
/// and the user may move or delete the source), so the bytes are copied into
/// `<app-documents>/ringtones/<uuid>.<ext>` and that durable path is what gets
/// persisted into [FakeCallConfig.customRingtonePath].
///
/// [opener], [docsDirProvider], and [uuidGenerator] exist purely as test seams
/// so the import flow is host-testable without platform channels; production
/// code leaves them at their defaults (assigned inside the body, never as
/// default parameter values, so the signature stays dependency-light).
class RingtonePicker {
  /// Creates a [RingtonePicker].
  ///
  /// [opener] selects a single audio file (defaults to `file_selector`'s
  /// `openFile`). [docsDirProvider] resolves the app-documents directory
  /// (defaults to `path_provider`'s `getApplicationDocumentsDirectory`).
  /// [uuidGenerator] names the stored copy (defaults to a v4 UUID).
  RingtonePicker({
    Future<XFile?> Function(List<XTypeGroup> acceptedTypeGroups)? opener,
    Future<Directory> Function()? docsDirProvider,
    String Function()? uuidGenerator,
  }) : _opener = opener ?? _defaultOpener,
       _docsDirProvider = docsDirProvider ?? getApplicationDocumentsDirectory,
       _uuidGenerator = uuidGenerator ?? _defaultUuid;

  final Future<XFile?> Function(List<XTypeGroup> acceptedTypeGroups) _opener;
  final Future<Directory> Function() _docsDirProvider;
  final String Function() _uuidGenerator;

  static Future<XFile?> _defaultOpener(List<XTypeGroup> acceptedTypeGroups) =>
      openFile(acceptedTypeGroups: acceptedTypeGroups);

  static String _defaultUuid() => const Uuid().v4();

  /// Opens the audio picker, copies the chosen file into app-internal
  /// storage, and returns the stored path (or `null` on cancel).
  ///
  /// The copy is named with a fresh UUID and keeps the source extension so the
  /// audio backend can sniff the container. Throws if the copy itself fails
  /// (an I/O error on the app's own storage is a genuine failure the caller
  /// should surface — distinct from a *missing* file at play time, which the
  /// audio service degrades past).
  Future<String?> pickAndStoreRingtone() async {
    final XFile? picked = await _opener(<XTypeGroup>[
      const XTypeGroup(label: 'audio', extensions: kRingtoneExtensions),
    ]);
    if (picked == null) {
      return null;
    }

    final Directory docsDir = await _docsDirProvider();
    final Directory ringtoneDir = Directory(p.join(docsDir.path, 'ringtones'));
    if (!ringtoneDir.existsSync()) {
      ringtoneDir.createSync(recursive: true);
    }

    final String ext = _extensionFor(picked);
    final String storedPath = p.join(
      ringtoneDir.path,
      '${_uuidGenerator()}$ext',
    );

    final bytes = await picked.readAsBytes();
    await File(storedPath).writeAsBytes(bytes, flush: true);
    log('pickAndStoreRingtone — stored $storedPath', name: 'RingtonePicker');
    return storedPath;
  }

  /// Derives a leading-dot file extension for the stored copy from the picked
  /// file's name, defaulting to `.mp3` when the source carries no usable
  /// extension (so the backend always has a container hint).
  static String _extensionFor(XFile picked) {
    final String ext = p.extension(picked.name).toLowerCase();
    if (ext.isEmpty || ext == '.') {
      return '.mp3';
    }
    return ext;
  }
}
