import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/core/theme/guardian_angela_logo.dart';
import 'package:guardianangela/features/home/home_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Home dashboard.
///
/// Shows the Guardian Angela brand, mode selector, contact chips, and
/// the primary "Start Session" and "Simulate" buttons. Settings,
/// contacts, and history live in the app bar. See spec 04 §Home Screen.
class HomeScreen extends ConsumerWidget {
  /// Creates a [HomeScreen].
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    }
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
