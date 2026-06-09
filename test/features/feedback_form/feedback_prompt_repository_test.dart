/// Unit tests for [FeedbackPromptRepository] — the SharedPreferences-backed
/// counter that gates the optional post-session feedback prompt (spec 04
/// §Chain Exhausted Screen — Tier-F F5, "appears after 3 successful
/// sessions"). Exercises the real read/write/round-trip paths plus the
/// no-throw fallbacks.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:guardianangela/features/feedback_form/feedback_prompt_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FeedbackPromptRepository — defaults', () {
    setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

    test('completedCount defaults to 0', () async {
      final repo = FeedbackPromptRepository();
      check(await repo.completedCount()).equals(0);
    });

    test('shouldShowPrompt is false before any completion', () async {
      final repo = FeedbackPromptRepository();
      check(await repo.shouldShowPrompt()).isFalse();
    });
  });

  group('FeedbackPromptRepository — counting', () {
    setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

    test(
      'recordCompletedSession increments and returns the new count',
      () async {
        final repo = FeedbackPromptRepository();
        check(await repo.recordCompletedSession()).equals(1);
        check(await repo.recordCompletedSession()).equals(2);
        check(await repo.completedCount()).equals(2);
      },
    );

    test('shouldShowPrompt is false below the threshold', () async {
      final repo = FeedbackPromptRepository();
      await repo.recordCompletedSession();
      await repo.recordCompletedSession();
      check(await repo.completedCount()).equals(2);
      // Threshold is 3 — two completions must not yet offer the prompt.
      check(await repo.shouldShowPrompt()).isFalse();
    });

    test('shouldShowPrompt flips true exactly at the threshold', () async {
      final repo = FeedbackPromptRepository();
      await repo.recordCompletedSession();
      await repo.recordCompletedSession();
      check(await repo.shouldShowPrompt()).isFalse();
      await repo.recordCompletedSession();
      check(
        await repo.completedCount(),
      ).equals(FeedbackPromptRepository.promptThreshold);
      check(await repo.shouldShowPrompt()).isTrue();
    });

    test('shouldShowPrompt stays true beyond the threshold', () async {
      final repo = FeedbackPromptRepository();
      for (var i = 0; i < 5; i++) {
        await repo.recordCompletedSession();
      }
      check(await repo.completedCount()).equals(5);
      check(await repo.shouldShowPrompt()).isTrue();
    });

    test('a pre-seeded count is honoured', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        FeedbackPromptRepository.completedCountKey: 3,
      });
      final repo = FeedbackPromptRepository();
      check(await repo.completedCount()).equals(3);
      check(await repo.shouldShowPrompt()).isTrue();
    });
  });

  group('FeedbackPromptRepository — no-throw fallbacks', () {
    test(
      'a throwing prefs loader degrades to no-prompt, never throws',
      () async {
        final repo = FeedbackPromptRepository(
          prefsLoader: () =>
              Future<SharedPreferences>.error(StateError('prefs unavailable')),
        );
        // All paths swallow the error and fall back to the safe "do not show".
        check(await repo.completedCount()).equals(0);
        check(await repo.recordCompletedSession()).equals(0);
        check(await repo.shouldShowPrompt()).isFalse();
      },
    );
  });
}
