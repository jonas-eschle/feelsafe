import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:home_widget/home_widget.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/core/theme/guardian_angela_logo.dart';
import 'package:guardianangela/domain/enums/home_widget_status.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/features/home/home_controller.dart';
import 'package:guardianangela/features/home/widgets/chain_summary.dart';
import 'package:guardianangela/features/home/widgets/safety_setup_checklist.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Home dashboard.
///
/// Shows the Guardian Angela brand, mode selector, contact chips, and
/// the primary "Start Session" and "Simulate" buttons. Settings,
/// contacts, and history live in the app bar. See spec 04 §Home Screen.
///
/// Also owns the home-screen widget lifecycle:
/// - Registers the interactivity callback on first mount (spec 04
///   §Home Screen Widget: "HomeScreen registers the interactivity callback").
/// - Drains [HomeWidget.initiallyLaunchedFromHomeWidget] to route cold-start
///   widget taps.
/// - Subscribes to [HomeWidget.widgetClicked] for foreground taps and routes
///   them to the correct destination.
/// - Publishes an initial Idle status and supplies pre-localised labels to
///   [SessionController] once the locale is resolved.
class HomeScreen extends ConsumerStatefulWidget {
  /// Creates a [HomeScreen].
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  StreamSubscription<Uri?>? _widgetClickedSub;

  @override
  void initState() {
    super.initState();
    // Register the Android interactivity callback once. The real service
    // delegates to HomeWidget.registerInteractivityCallback; the sim service
    // is a no-op. Done in initState (before first build) so the callback is
    // registered before any tap can arrive.
    ref.read(homeWidgetServiceProvider).registerCallback();

    // Subscribe to foreground widget taps. Guarded with try-catch because the
    // EventChannel is unavailable in unit / golden tests that do not mock the
    // 'home_widget/updates' platform channel.
    try {
      _widgetClickedSub = HomeWidget.widgetClicked.listen(_onWidgetUri);
    } catch (e) {
      log(
        'HomeScreen: widgetClicked subscription failed (non-fatal): $e',
        name: 'HomeScreen',
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Publish the initial Idle status and supply localised labels once
    // the locale is available. didChangeDependencies is called after
    // initState when the context's inherited dependencies are first resolved.
    _publishIdleAndConfigureLabels();
    // Drain any cold-start URI from the widget (app launched via widget tap).
    _drainColdStartUri();
  }

  @override
  void dispose() {
    _widgetClickedSub?.cancel();
    super.dispose();
  }

  void _publishIdleAndConfigureLabels() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    // Supply pre-localised labels to SessionController so it can publish
    // widget updates without a BuildContext.
    ref
        .read(sessionControllerProvider.notifier)
        .configureWidgetLabels(
          statusIdle: l10n.homeWidgetStatusIdle,
          statusSession: l10n.homeWidgetStatusSession,
          statusSim: l10n.homeWidgetStatusSim,
          quickExit: l10n.homeWidgetQuickExit,
          fakeCall: l10n.homeWidgetFakeCall,
        );
    // Publish initial Idle status so the widget reflects the current state.
    ref
        .read(homeWidgetServiceProvider)
        .publishStatus(
          status: HomeWidgetStatus.idle,
          statusText: l10n.homeWidgetStatusIdle,
          quickExitLabel: l10n.homeWidgetQuickExit,
          fakeCallLabel: l10n.homeWidgetFakeCall,
        )
        .ignore();
  }

  Future<void> _drainColdStartUri() async {
    try {
      final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      if (uri != null && mounted) {
        _routeWidgetUri(uri);
      }
    } catch (e) {
      log(
        'HomeScreen: cold-start widget URI drain failed: $e',
        name: 'HomeScreen',
      );
    }
  }

  void _onWidgetUri(Uri? uri) {
    if (uri == null || !mounted) return;
    _routeWidgetUri(uri);
  }

  void _routeWidgetUri(Uri uri) {
    // Only handle guardianangela:// deep links from the widget.
    if (uri.scheme != 'guardianangela') return;
    switch (uri.host) {
      case 'quick-exit':
        // Quick Exit is PIN-gated via the existing session-end flow in
        // SessionScreen._endSessionFlow. We navigate to /session with
        // quickExit=true so SessionScreen auto-triggers that flow once.
        // No-op when no session is active (spec 04 §Home Screen Widget).
        final sessionState = ref.read(sessionControllerProvider).value;
        if (sessionState != null &&
            sessionState.phase != SessionPhase.idle &&
            sessionState.phase != SessionPhase.ended) {
          context.pushNamed(
            RouteNames.session,
            queryParameters: const <String, String>{'quickExit': 'true'},
          );
        }
      case 'fake-call':
        context.pushNamed(RouteNames.fakeCall);
      default:
        log(
          'HomeScreen: unknown widget URI path: ${uri.host}',
          name: 'HomeScreen',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stateAsync = ref.watch(homeControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.homeMenuContacts,
            icon: const Icon(Icons.people_outline),
            onPressed: () => context.pushNamed(RouteNames.contacts),
          ),
          IconButton(
            tooltip: l10n.homeMenuHistory,
            icon: const Icon(Icons.history),
            onPressed: () => context.pushNamed(RouteNames.pastEvents),
          ),
          IconButton(
            tooltip: l10n.homeMenuSettings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.pushNamed(RouteNames.settings),
          ),
        ],
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(child: Text('Error: $e')),
        data: (HomeState state) => _HomeBody(state: state),
      ),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SafetySetupChecklist(contacts: state.contacts, modes: state.modes),
            const Center(child: GuardianAngelaLogo()),
            const SizedBox(height: 8),
            Center(child: Text(l10n.homeTitle, style: textTheme.titleLarge)),
            Center(child: Text(l10n.homeTagline, style: textTheme.bodyMedium)),
            const SizedBox(height: 24),
            if (state.modes.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.homeNoModes),
                ),
              )
            else
              _ModeSelector(state: state),
            if (state.selectedModeId != null && state.modes.isNotEmpty) ...[
              const SizedBox(height: 16),
              ChainSummary(
                steps: state.modes
                    .firstWhere(
                      (SessionMode m) => m.id == state.selectedModeId,
                      orElse: () => state.modes.first,
                    )
                    .chainSteps,
              ),
            ],
            const SizedBox(height: 16),
            if (state.contacts.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.homeContactsBannerNone),
                ),
              )
            else
              _ContactChips(state: state),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.shield_outlined),
              onPressed: state.selectedModeId == null
                  ? null
                  : () => _onStart(context, ref, simulate: false),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(64),
              ),
              label: Text(l10n.homeStartSession),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: state.selectedModeId == null
                  ? null
                  : () => _onStart(context, ref, simulate: true),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(l10n.homeSimulate),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onStart(
    BuildContext context,
    WidgetRef ref, {
    required bool simulate,
  }) async {
    final ok = await ref
        .read(homeControllerProvider.notifier)
        .startSession(simulate: simulate);
    if (!context.mounted) return;
    if (ok) {
      await context.pushNamed<void>(RouteNames.session);
      return;
    }
    final errors = ref.read(homeControllerProvider).value?.lastValidationErrors;
    if (errors != null && errors.isNotEmpty) {
      await _showStartErrors(context, ref, errors);
    }
  }

  Future<void> _showStartErrors(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> errors,
  ) async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(l10n.sessionStartFailedTitle),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(l10n.sessionStartFailedBody),
              const SizedBox(height: 8),
              for (final issue in errors)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text('• ${(issue as dynamic).title}'),
                ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.commonOk),
          ),
        ],
      ),
    );
    ref.read(homeControllerProvider.notifier).clearValidationErrors();
  }
}

class _ModeSelector extends ConsumerWidget {
  const _ModeSelector({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final mode in state.modes)
          ChoiceChip(
            label: Text(mode.name),
            selected: state.selectedModeId == mode.id,
            onSelected: (bool s) {
              if (s) {
                ref.read(homeControllerProvider.notifier).selectMode(mode.id);
              }
            },
          ),
      ],
    );
  }
}

class _ContactChips extends StatelessWidget {
  const _ContactChips({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final visible = state.contacts.take(5).toList();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final c in visible)
          ActionChip(
            avatar: CircleAvatar(
              child: Text(c.name.characters.first.toUpperCase()),
            ),
            label: Text(c.name),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        if (state.contacts.length > 5)
          ActionChip(
            label: Text('+${state.contacts.length - 5}'),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
      ],
    );
  }
}
