import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Active session screen.
///
/// Orientation is locked to portrait (D3) while this screen is mounted.
/// Renders different UI per step type (hold button, disguised reminder,
/// countdown, escalation). See spec 04 §Session Screen.
class SessionScreen extends ConsumerStatefulWidget {
  /// Creates a [SessionScreen].
  const SessionScreen({super.key});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(sessionControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sessionTitle),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: l10n.commonClose,
            onPressed: () => _confirmEnd(context),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(child: Text('Error: $e')),
        data: (SessionState s) => _SessionBody(state: s),
      ),
    );
  }

  Future<void> _confirmEnd(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(l10n.sessionEndConfirmTitle),
        content: Text(l10n.sessionEndConfirmSwipe),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );
    if (shouldEnd == true && context.mounted) {
      context.goNamed(RouteNames.sessionCompleted);
    }
  }
}

class _SessionBody extends StatelessWidget {
  const _SessionBody({required this.state});

  final SessionState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (state.isSimulation)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange, width: 4),
              ),
              child: Center(
                child: Text(
                  '[SIM] ${l10n.sessionSimulationBanner}',
                  style: textTheme.titleMedium,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            l10n.homeActiveSession,
            style: textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.sessionHoldPrompt,
            style: textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'HOLD',
                  style: textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
