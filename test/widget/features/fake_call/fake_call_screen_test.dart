import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safewayhome/data/models/fake_call_config.dart';
import 'package:safewayhome/features/fake_call/fake_call_controller.dart';
import 'package:safewayhome/features/fake_call/fake_call_screen.dart';
import 'package:safewayhome/l10n/app_localizations.dart';
import 'package:safewayhome/services/audio_service.dart';
import 'package:safewayhome/services/service_providers.dart';

class MockAudioService extends Mock implements AudioService {}

Widget _wrapWithProviders(Widget child, List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: child,
    ),
  );
}

void main() {
  late MockAudioService mockAudio;

  setUp(() {
    mockAudio = MockAudioService();
    when(() => mockAudio.playRingtone()).thenAnswer((_) async {});
    when(() => mockAudio.stop()).thenAnswer((_) async {});
  });

  group('FakeCallScreen', () {
    testWidgets('shows caller name', (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(
          const FakeCallScreen(),
          [
            audioServiceProvider.overrideWithValue(mockAudio),
            fakeCallConfigProvider
                .overrideWith(() => _FakeCallConfigController(
                      FakeCallConfig(callerName: 'Dad'),
                    )),
          ],
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Dad'), findsOneWidget);
    });

    testWidgets('shows caller initial in avatar when no photo',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(
          const FakeCallScreen(),
          [
            audioServiceProvider.overrideWithValue(mockAudio),
            fakeCallConfigProvider
                .overrideWith(() => _FakeCallConfigController(
                      FakeCallConfig(callerName: 'Mom'),
                    )),
          ],
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('M'), findsOneWidget);
    });

    testWidgets('decline button is present (red circle)', (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(
          const FakeCallScreen(),
          [
            audioServiceProvider.overrideWithValue(mockAudio),
            fakeCallConfigProvider
                .overrideWith(() => _FakeCallConfigController(
                      FakeCallConfig(),
                    )),
          ],
        ),
      );
      await tester.pump();
      await tester.pump();

      // Decline button has call_end icon
      expect(find.byIcon(Icons.call_end), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);
    });

    testWidgets('slide to answer widget renders', (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(
          const FakeCallScreen(),
          [
            audioServiceProvider.overrideWithValue(mockAudio),
            fakeCallConfigProvider
                .overrideWith(() => _FakeCallConfigController(
                      FakeCallConfig(),
                    )),
          ],
        ),
      );
      await tester.pump();
      await tester.pump();

      // The slide to answer text
      expect(find.text('Slide to answer'), findsOneWidget);
      // Green call icon (the thumb)
      expect(find.byIcon(Icons.call), findsOneWidget);
    });

    testWidgets('shows incoming call text', (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(
          const FakeCallScreen(),
          [
            audioServiceProvider.overrideWithValue(mockAudio),
            fakeCallConfigProvider
                .overrideWith(() => _FakeCallConfigController(
                      FakeCallConfig(),
                    )),
          ],
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Incoming call...'), findsOneWidget);
    });

    testWidgets('playRingtone is called on init', (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(
          const FakeCallScreen(),
          [
            audioServiceProvider.overrideWithValue(mockAudio),
            fakeCallConfigProvider
                .overrideWith(() => _FakeCallConfigController(
                      FakeCallConfig(),
                    )),
          ],
        ),
      );
      await tester.pump();
      await tester.pump();

      verify(() => mockAudio.playRingtone()).called(1);
    });
  });
}

class _FakeCallConfigController extends FakeCallConfigController {
  final FakeCallConfig _config;

  _FakeCallConfigController(this._config);

  @override
  Future<FakeCallConfig> build() async => _config;
}
