/// Supplemental tests for [ChainStepTile] covering the preview button
/// and [_openPreview] method:
///   - line 70: `onPressed: () => _openPreview(context, mId)` — fires when
///     modeId is non-null and the play-arrow icon is tapped.
///   - lines 126-131: `_openPreview` — constructs the URI with stepId +
///     modeId query params and calls `GoRouter.of(context).push`.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/features/modes/widgets/chain_step_tile.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ChainStep _step({String id = 'step-abc'}) => ChainStep(
  id: id,
  type: ChainStepType.holdButton,
  order: 0,
  durationSeconds: 30,
  gracePeriodSeconds: 5,
  waitSeconds: 0,
  retryCount: 0,
  randomize: 0,
);

/// Hosts a ChainStepTile inside a GoRouter that records pushed paths.
///
/// [pushed] is populated whenever a navigation to [RouteNames.stepPreview]
/// occurs, allowing assertions about the URI constructed by [_openPreview].
Widget _hostWithStepPreviewRoute({
  required ChainStep step,
  required List<String> pushed,
  String? modeId,
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (ctx, st) => Scaffold(
          body: SingleChildScrollView(
            child: ChainStepTile(
              step: step,
              onChanged: (_) {},
              onDelete: () {},
              modeId: modeId,
            ),
          ),
        ),
      ),
      GoRoute(
        path: RouteNames.stepPreview,
        builder: (ctx, st) {
          pushed.add(st.uri.toString());
          return const Scaffold(body: Text('Preview'));
        },
      ),
    ],
  );
  return ProviderScope(
    child: MaterialApp.router(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ChainStepTile — preview button (line 70)', () {
    testWidgets('preview icon hidden when modeId is null', (tester) async {
      await tester.pumpWidget(
        _hostWithStepPreviewRoute(
          step: _step(),
          pushed: [],
          // modeId omitted → null → preview icon absent.
        ),
      );
      await tester.pumpAndSettle();
      check(find.byIcon(Icons.play_arrow_outlined).evaluate()).isEmpty();
    });

    testWidgets('preview icon visible when modeId is provided', (tester) async {
      await tester.pumpWidget(
        _hostWithStepPreviewRoute(step: _step(), pushed: [], modeId: 'mode-1'),
      );
      await tester.pumpAndSettle();
      check(find.byIcon(Icons.play_arrow_outlined).evaluate()).isNotEmpty();
    });

    testWidgets(
      '_openPreview pushes stepPreview URI with stepId + modeId (lines 126–131)',
      (tester) async {
        final pushed = <String>[];
        final step = _step(id: 'step-xyz');

        await tester.pumpWidget(
          _hostWithStepPreviewRoute(
            step: step,
            pushed: pushed,
            modeId: 'mode-42',
          ),
        );
        await tester.pumpAndSettle();

        // Tap the preview (play arrow) icon to fire _openPreview.
        final previewIcon = find.byIcon(Icons.play_arrow_outlined);
        check(previewIcon.evaluate()).isNotEmpty();
        await tester.tap(previewIcon);
        await tester.pumpAndSettle();

        // GoRouter should have navigated to the stepPreview route.
        check(pushed).isNotEmpty();
        // The URI must contain both query parameters.
        final uri = pushed.first;
        check(uri).contains('stepId=step-xyz');
        check(uri).contains('modeId=mode-42');
      },
    );
  });
}
