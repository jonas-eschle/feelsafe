/// Locale smoke tests — every supported locale loads its
/// [AppLocalizations] and renders without throwing on a placeholder
/// substitution or leaking a `<MISSING TRANSLATION>` token. Mirrors the
/// Phase 8 gate "home screen renders in every locale without a
/// `<MISSING TRANSLATION>` token" (spec 00 §Localization;
/// `~/.claude/plans/rippling-weaving-puffin.md` §Phase 8).
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Calls every placeholder-bearing localization method with dummy
/// arguments. A malformed translation (dropped/renamed placeholder or
/// broken ICU) then surfaces as a thrown exception or an empty result.
/// ICU plural messages (stepSummaryRetryCount, stepSummarySmsMore) are
/// exercised at several counts so every CLDR category arm of every
/// locale (ru/uk few+many, ar zero/one/two/few/many, he one/two/many)
/// actually evaluates.
List<String> _allParameterizedStrings(AppLocalizations l) => <String>[
  l.onboardingUseSimNumberHint('+15550100'),
  l.homeChainSummaryTimingTitle('Walk'),
  l.homeChainSummaryWait(5),
  l.homeChainSummaryDuration(30),
  l.homeChainSummaryGrace(5),
  l.homeChainSummaryRetry(2),
  l.homeChainSummaryNextStep('SMS'),
  l.homeChecklistProgress(3, 6),
  l.sessionStepLabel(2, 5),
  l.sessionMissCount(1),
  l.sessionStepCallEmergencyNumber('112'),
  l.sessionStepHardwareButtonRepeat('Volume up', 3, 1500),
  l.sessionStepHardwareButtonLong('Volume up', 2),
  l.fakeCallVoicePrompt('Alex'),
  l.fakeCallVibrationLabel('SOS'),
  l.fakeCallActiveDuration('01', '23'),
  l.contactDeleteBody('Alex'),
  l.modesNewPickerFromTemplate('Walk'),
  l.stepTimingSummary(5, 30, 5),
  l.stepSummaryHoldButton('largeButton', 5),
  l.stepSummaryDisguisedReminder('30 min', l.stepSummaryRetryCount(3)),
  for (final int count in <int>[0, 1, 2, 3, 5, 11, 21, 100])
    l.stepSummaryRetryCount(count),
  l.stepSummaryMinutes(30),
  l.stepSummarySeconds(45),
  l.stepSummaryCountdown(10, 'fullScreen'),
  l.stepSummaryFakeCall(30, 5),
  l.stepSummarySmsTo('Alice, Bob'),
  for (final int count in <int>[1, 2, 3, 5, 11, 21, 100])
    l.stepSummarySmsMore(count),
  l.stepSummaryPhoneCall('Alex'),
  l.stepSummaryLoudAlarm(80, 'siren'),
  l.stepSummaryLoudAlarmRamp(80, 'siren'),
  l.stepSummaryCallEmergency('112'),
  l.stepSummaryCallEmergencySmsFirst('112'),
  l.stepSummaryHardwareRepeat('volumeUp', 3),
  l.stepSummaryHardwareLong('volumeUp', '2'),
  l.aboutVersion('3.0.0'),
  l.sessionInterruptedMode('Walk'),
  l.sessionInterruptedStarted('12:00'),
  l.distressConfirmCountdown(10),
  l.distressCancelPinTimeoutLabel(30),
  l.simulationSummaryDuration('2m'),
  l.simulationSummaryMissedEventsBadge(1),
  l.simulationSummaryDistressBadge(1),
  l.simulationSummaryStepsFiredBadge(3),
  l.historyRetentionPurged(4),
  l.templatesDeleteConfirmTitle('Reminder'),
  l.aboutBundleId('com.guardianangela.app'),
  l.aboutPlatforms('Android, iOS'),
  l.backupImportError('bad file'),
  l.backupLastBackupAtLabel('yesterday'),
  l.modesDeleteConfirmBody('Walk'),
  l.sessionHoldReleaseCountdown(3),
  l.sessionHoldGraceCountdown(5),
  l.sessionStepNextCheckIn('12:30'),
  l.sessionStepFakeCallActive('Alex'),
  l.sessionStepSimBlockedSms(2),
  l.pastEventsTrashEmptyAllSuccess(5),
  l.pastEventsTrashRetentionNote(30),
  l.pastEventsTrashRemainingDays(7),
  l.sessionEmergencyConfirmTitle('112', 5),
];

void main() {
  test('exactly 14 supported locales are declared', () {
    check(AppLocalizations.supportedLocales.length).equals(14);
  });

  group('every supported locale loads & substitutes placeholders', () {
    for (final Locale locale in AppLocalizations.supportedLocales) {
      test('${locale.toLanguageTag()} resolves non-empty strings', () async {
        final AppLocalizations l10n = await AppLocalizations.delegate.load(
          locale,
        );
        // Representative plain getters resolve.
        for (final String s in <String>[
          l10n.appTitle,
          l10n.homeTitle,
          l10n.homeChecklistTitle,
          l10n.homeChecklistAllDoneBanner,
        ]) {
          check(s.trim().isNotEmpty).isTrue();
          check(s.contains('<MISSING TRANSLATION>')).isFalse();
        }
        // Every placeholder-bearing message substitutes without throwing.
        for (final String s in _allParameterizedStrings(l10n)) {
          check(s.trim().isNotEmpty).isTrue();
          check(s.contains('<MISSING TRANSLATION>')).isFalse();
        }
      });
    }
  });

  testWidgets('a localized screen renders in every locale without exceptions', (
    WidgetTester tester,
  ) async {
    for (final Locale locale in AppLocalizations.supportedLocales) {
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              final AppLocalizations l10n = AppLocalizations.of(context);
              return Scaffold(
                appBar: AppBar(title: Text(l10n.homeTitle)),
                body: Column(
                  children: <Widget>[
                    Text(l10n.appTitle),
                    Text(l10n.homeChecklistProgress(3, 6)),
                    Text(l10n.homeChecklistAllDoneBanner),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      check(tester.takeException()).isNull();
      expect(find.textContaining('<MISSING TRANSLATION>'), findsNothing);
    }
  });
}
