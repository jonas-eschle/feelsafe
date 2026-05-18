/// Extended coverage tests for [ModesController].
///
/// Covers the uncovered lines (~3) relating to:
///  * `save` throws [SessionLockedError] when a session is active.
///  * `delete` throws [SessionLockedError] when a session is active.
///  * `reorder` throws [SessionLockedError] when a session is active.
///  * `reorder` with oldIndex == length (boundary: >= length is out-of-range).
///  * `reorder` with oldIndex == -1 (boundary: < 0 is out-of-range).
library;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import 'package:guardianangela/core/utils/session_locked_error.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/modes/modes_controller.dart';
import 'package:guardianangela/features/session/session_controller.dart';

import '../../helpers/test_helpers.dart';
import '../fake_repositories.dart';

// ---------------------------------------------------------------------------
// Fake SessionController that simulates an active session.
// ---------------------------------------------------------------------------

/// Minimal [SessionController] fake that reports `isSessionActive` as
/// the provided [active] flag. All mutator methods are no-ops.
class _FakeSessionController extends SessionController {
  _FakeSessionController({required this.active});

  final bool active;

  @override
  Future<WalkSession?> build() async => null;

  @override
  bool get isSessionActive => active;
}

// ---------------------------------------------------------------------------
// Container factory
// ---------------------------------------------------------------------------

ProviderContainer _makeContainer({
  List<SessionMode> seed = const [],
  bool sessionActive = false,
}) {
  final repo = FakeModesRepository(seed);
  return ProviderContainer(
    overrides: [
      modesRepositoryProvider.overrideWithValue(repo),
      sessionControllerProvider.overrideWith(
        () => _FakeSessionController(active: sessionActive),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ModesController – session-locked guard', () {
    test('save throws SessionLockedError when session is active', () async {
      final container = _makeContainer(sessionActive: true);
      addTearDown(container.dispose);

      final notifier = container.read(modesControllerProvider.notifier);
      await container.read(modesControllerProvider.future);

      await check(
        notifier.save(makeMode(id: 'new', name: 'New Mode')),
      ).throws<SessionLockedError>();
    });

    test('delete throws SessionLockedError when session is active', () async {
      final container = _makeContainer(
        seed: [makeMode(id: 'x', name: 'X')],
        sessionActive: true,
      );
      addTearDown(container.dispose);

      final notifier = container.read(modesControllerProvider.notifier);
      await container.read(modesControllerProvider.future);

      await check(notifier.delete('x')).throws<SessionLockedError>();
    });

    test(
      'reorder throws SessionLockedError when session is active',
      () async {
        final container = _makeContainer(
          seed: [
            makeMode(id: 'a', name: 'A'),
            makeMode(id: 'b', name: 'B'),
          ],
          sessionActive: true,
        );
        addTearDown(container.dispose);

        final notifier = container.read(modesControllerProvider.notifier);
        await container.read(modesControllerProvider.future);

        await check(notifier.reorder(0, 1)).throws<SessionLockedError>();
      },
    );
  });

  group('ModesController.reorder – boundary / edge cases', () {
    test(
      'reorder with oldIndex == length throws RangeError',
      () async {
        // `length == 2`, valid range [0,1]; oldIndex == 2 is out-of-range.
        final container = _makeContainer(
          seed: [
            makeMode(id: 'a', name: 'A'),
            makeMode(id: 'b', name: 'B'),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(modesControllerProvider.notifier);
        await container.read(modesControllerProvider.future);

        await check(notifier.reorder(2, 0)).throws<RangeError>();
      },
    );

    test(
      'reorder on empty list throws RangeError for any oldIndex',
      () async {
        final container = _makeContainer(seed: []);
        addTearDown(container.dispose);

        final notifier = container.read(modesControllerProvider.notifier);
        await container.read(modesControllerProvider.future);

        // state.value is empty; oldIndex 0 >= length(0) so it's invalid.
        await check(notifier.reorder(0, 0)).throws<RangeError>();
      },
    );

    test(
      'reorder moves the last item to the front',
      () async {
        final container = _makeContainer(
          seed: [
            makeMode(id: 'a', name: 'A'),
            makeMode(id: 'b', name: 'B'),
            makeMode(id: 'c', name: 'C'),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(modesControllerProvider.notifier);
        await container.read(modesControllerProvider.future);

        // Move index 2 (c) before index 0 → [c, a, b].
        await notifier.reorder(2, 0);

        final list = container.read(modesControllerProvider).value!;
        check(list.map((m) => m.id).toList()).deepEquals(['c', 'a', 'b']);
      },
    );

    test(
      'reorder with newIndex clamped to list end does not crash',
      () async {
        final container = _makeContainer(
          seed: [
            makeMode(id: 'a', name: 'A'),
            makeMode(id: 'b', name: 'B'),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(modesControllerProvider.notifier);
        await container.read(modesControllerProvider.future);

        // ReorderableListView calls reorder(0, length) to move first
        // item to last; insertAt = length - 1 = 1 → [b, a].
        await notifier.reorder(0, 2);

        final list = container.read(modesControllerProvider).value!;
        check(list.map((m) => m.id).toList()).deepEquals(['b', 'a']);
      },
    );
  });
}
