import 'dart:developer';
import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import 'package:guardianangela/services/protocols/audio_service_protocol.dart';

/// Default TTS prompt text for each supported locale (D14).
///
/// Keyed by the same locale codes as [_builtInVoicePaths]. Used by
/// [RealAudioService.bootstrapVoiceAssets] when the ARB key
/// `fakeCallVoicePromptDefault` is not yet populated (Phase 8 ARB scrum
/// will replace these hardcoded strings with the translated ARB values).
const Map<String, String> _builtInVoicePrompts = {
  'en': "Hey, it's Angela, just checking in. Can you call me back?",
  'de':
      'Hey, hier ist Angela, ich wollte nur kurz nachfragen. Kannst du '
      'mich zurückrufen?',
  'es': 'Hola, soy Angela, solo quería saber cómo estás. ¿Me puedes llamar?',
  'fr':
      'Salut, c\'est Angela, je voulais juste prendre des nouvelles. '
      'Tu peux me rappeler?',
  'ru':
      'Привет, это Анжела, просто хочу узнать, как ты. '
      'Ты можешь перезвонить мне?',
  'zh': '嘿，我是Angela，只是想确认一下你是否安好。你能给我回电吗？',
  'zh_TW': '嘿，我是Angela，只是想確認你是否安好。你能給我回電嗎？',
  'hi':
      'हाय, मैं Angela हूँ, बस यह जानना चाहती थी कि तुम ठीक हो। '
      'क्या तुम मुझे वापस कॉल कर सकते हो?',
  'fa':
      'سلام، من آنجلا هستم، فقط می‌خواستم حالت را بپرسم. '
      'می‌توانی به من زنگ بزنی؟',
  'uk':
      'Привіт, це Анджела, просто хотіла дізнатися, як ти. '
      'Ти можеш мені передзвонити?',
  'pl':
      'Hej, to Angela, chciałam tylko sprawdzić, czy wszystko w porządku. '
      'Czy możesz do mnie oddzwonić?',
  'el':
      'Γεια, είμαι η Angela, ήθελα απλώς να δω πώς είσαι. '
      'Μπορείς να με πάρεις τηλέφωνο;',
  'ar': 'مرحباً، أنا أنجيلا، أردت فقط الاطمئنان عليك. هل يمكنك الاتصال بي؟',
  'he': 'היי, זאת אנג\'לה, רציתי לבדוק שהכל בסדר. האם אתה יכול להתקשר אלי?',
};

/// Built-in voice asset paths keyed by ISO 639-1 code (or `zh_TW`).
///
/// This map is the single source of truth — keep in sync with the
/// `flutter: assets:` manifest entry `assets/voice/` in `pubspec.yaml`
/// and with the table at spec 05 §AudioService §Built-in Voice Recordings.
const Map<String, String> _builtInVoicePaths = {
  'en': 'assets/voice/angela_en.m4a',
  'de': 'assets/voice/angela_de.m4a',
  'es': 'assets/voice/angela_es.m4a',
  'fr': 'assets/voice/angela_fr.m4a',
  'ru': 'assets/voice/angela_ru.m4a',
  'zh': 'assets/voice/angela_zh.m4a',
  'zh_TW': 'assets/voice/angela_zh_TW.m4a',
  'hi': 'assets/voice/angela_hi.m4a',
  'fa': 'assets/voice/angela_fa.m4a',
  'uk': 'assets/voice/angela_uk.m4a',
  'pl': 'assets/voice/angela_pl.m4a',
  'el': 'assets/voice/angela_el.m4a',
  'ar': 'assets/voice/angela_ar.m4a',
  'he': 'assets/voice/angela_he.m4a',
};

/// Default voice asset path used when locale resolution fails.
const String _defaultVoicePath = 'assets/voice/angela_en.m4a';

/// Resolves the built-in voice asset path for the current locale.
///
/// Fallback resolution order per spec 05 §AudioService §Fallback:
/// 1. Full tag match (handles `zh_TW`).
/// 2. Language prefix match (`en_US` → `en`).
/// 3. English fallback + logged warning.
String resolveBuiltInVoicePath(String localeName) {
  // 1. Full-tag match (e.g. "zh_TW").
  if (_builtInVoicePaths.containsKey(localeName)) {
    return _builtInVoicePaths[localeName]!;
  }

  // 2. Language-prefix match (e.g. "en_US" → "en").
  final prefix = localeName.split('_').first;
  if (_builtInVoicePaths.containsKey(prefix)) {
    return _builtInVoicePaths[prefix]!;
  }

  // 3. English fallback.
  log(
    'No built-in voice for locale "$localeName"; falling back to English',
    name: 'AudioService',
  );
  return _defaultVoicePath;
}

/// Production [AudioServiceProtocol] backed by `package:just_audio`.
///
/// Each public method creates or reuses the internal [AudioPlayer].
/// [stop] disposes the player; subsequent calls create a new one.
///
/// **Layer 3 simulation guard:** [playAlarmWithConfig] and
/// [playVoiceRecording] are no-ops when [isSimulation] is `true` per
/// spec 05 §Simulation Strategy Pattern §Layer 3.
///
/// **Voice asset bootstrap:** The actual M4A files under `assets/voice/`
/// are synthesized at first launch by `bootstrapVoiceAssets()` (Stage 5C).
/// The asset declarations in `pubspec.yaml` already list `assets/voice/`.
/// Until Stage 5C runs, missing asset files cause `just_audio` to throw
/// [PlayerException], which propagates to the caller as specified by spec
/// 05 §AudioService §Voice Recordings.
///
/// **Single constructor location rule:** no `RealAudioService()`
/// call may appear outside `lib/services/service_providers.dart`
/// (CI grep enforces).
class RealAudioService implements AudioServiceProtocol {
  /// Creates a [RealAudioService].
  ///
  /// [player] may be injected for tests; defaults to a new [AudioPlayer].
  /// [tts] may be injected for tests; defaults to a new [FlutterTts].
  RealAudioService({AudioPlayer? player, FlutterTts? tts})
    : _player = player ?? AudioPlayer(),
      _tts = tts ?? FlutterTts();

  AudioPlayer _player;
  final FlutterTts _tts;

  // ---------------------------------------------------------------------------
  // AudioServiceProtocol implementation
  // ---------------------------------------------------------------------------

  @override
  Future<void> playAlarmWithConfig({
    String soundChoice = 'siren',
    String? customSoundPath,
    double volume = 1.0,
    bool isSimulation = false,
  }) async {
    if (isSimulation) {
      log(
        '[SIM] playAlarmWithConfig — suppressed at Layer 3',
        name: 'AudioService',
      );
      return;
    }

    if (soundChoice == 'custom' && customSoundPath == null) {
      throw ArgumentError.value(
        customSoundPath,
        'customSoundPath',
        'Required when soundChoice is "custom"',
      );
    }

    final clampedVolume = volume.clamp(0.0, 1.0);
    log(
      'playAlarmWithConfig — soundChoice=$soundChoice volume=$clampedVolume',
      name: 'AudioService',
    );

    await _ensurePlayer();
    await _player.setVolume(clampedVolume);

    if (soundChoice == 'custom' && customSoundPath != null) {
      await _player.setFilePath(customSoundPath);
    } else {
      // 'siren' — built-in asset.
      await _player.setAsset('assets/audio/siren.ogg');
    }

    await _player.setLoopMode(LoopMode.all);
    await _player.play();
  }

  @override
  Future<void> playSound(String assetPath) async {
    log('playSound — $assetPath', name: 'AudioService');
    await _ensurePlayer();
    await _player.setAsset(assetPath);
    await _player.setLoopMode(LoopMode.off);
    await _player.play();
  }

  @override
  Future<void> stop() async {
    log('stop', name: 'AudioService');
    await _player.stop();
    await _player.dispose();
    // Create a fresh player for subsequent calls.
    _player = AudioPlayer();
  }

  // ---------------------------------------------------------------------------
  // Extended API (beyond the protocol minimum)
  // ---------------------------------------------------------------------------

  /// Plays a voice recording once.
  ///
  /// [filePath] — filesystem path to a user-recorded M4A/AAC-LC file, or
  /// `null` to fall back to the built-in language-specific asset.
  ///
  /// [useSpeaker] routes output through the speaker instead of the earpiece.
  ///
  /// [isSimulation] is a Layer-3 guard; when `true` this method is a no-op.
  ///
  /// Missing asset files cause [PlayerException] which propagates to the
  /// caller per spec 05 §AudioService §Voice Recordings.
  Future<void> playVoiceRecording(
    String? filePath, {
    bool useSpeaker = false,
    bool isSimulation = false,
  }) async {
    if (isSimulation) {
      log(
        '[SIM] playVoiceRecording — suppressed at Layer 3',
        name: 'AudioService',
      );
      return;
    }

    await _ensurePlayer();
    await _player.setLoopMode(LoopMode.off);

    if (filePath != null) {
      log('playVoiceRecording — file: $filePath', name: 'AudioService');
      await _player.setFilePath(filePath);
    } else {
      final assetPath = resolveBuiltInVoicePath(Platform.localeName);
      log('playVoiceRecording — built-in: $assetPath', name: 'AudioService');
      await _player.setAsset(assetPath);
    }

    await _player.play();
  }

  // ---------------------------------------------------------------------------
  // TTS voice-asset bootstrap (D14, spec 05 §AudioService §Voice Recordings)
  // ---------------------------------------------------------------------------

  /// Synthesizes the Angela check-in line for each of the 14 supported
  /// locales and writes the result to the app documents directory.
  ///
  /// Run once per locale on first launch (subsequent launches skip locales
  /// that already have a cached file). Runs sequentially to avoid TTS engine
  /// contention. Failures per locale are logged but never block app start
  /// (spec 05:149).
  ///
  /// The [onFailure] callback receives the locale code and the error; used by
  /// tests and `main.dart` to route failures to Sentry.
  Future<void> bootstrapVoiceAssets({
    void Function(String locale, Object error, StackTrace stack)? onFailure,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final voiceDir = Directory('${dir.path}/voice');
    if (!voiceDir.existsSync()) {
      voiceDir.createSync(recursive: true);
    }

    for (final locale in _builtInVoicePaths.keys) {
      final outPath = '${voiceDir.path}/angela_$locale.m4a';
      if (File(outPath).existsSync()) {
        log(
          'bootstrapVoiceAssets: $locale already cached — skip',
          name: 'AudioService',
        );
        continue;
      }

      final prompt =
          _builtInVoicePrompts[locale] ?? _builtInVoicePrompts['en']!;
      try {
        await _tts.setLanguage(_localeToTtsTag(locale));
        await _tts.synthesizeToFile(prompt, outPath);
        log(
          'bootstrapVoiceAssets: synthesized $locale → $outPath',
          name: 'AudioService',
        );
      } catch (e, st) {
        log(
          'bootstrapVoiceAssets: failed for $locale: $e',
          name: 'AudioService',
        );
        onFailure?.call(locale, e, st);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Resets the player if it has been disposed so it is safe to use.
  Future<void> _ensurePlayer() async {
    try {
      // Accessing processingState on a disposed player throws; if it throws
      // we replace the player.
      _player.processingState; // ignore: unnecessary_statements
    } catch (_) {
      _player = AudioPlayer();
    }
  }
}

/// Maps a locale code from [_builtInVoicePaths] to a BCP 47 / IETF tag
/// understood by [FlutterTts.setLanguage].
String _localeToTtsTag(String locale) => switch (locale) {
  'zh_TW' => 'zh-TW',
  'zh' => 'zh-CN',
  _ => locale,
};
