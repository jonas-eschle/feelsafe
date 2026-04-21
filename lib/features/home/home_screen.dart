/// Home / landing screen.
///
/// Shows the mode selector, the big "Start session" CTA, a simulate
/// toggle, and shortcuts to Modes / Contacts / Settings / History.
/// When a session is already running the Start button becomes a
/// "Resume" shortcut to the session screen.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/features/home/home_controller.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Landing screen for returning users.
class HomeScreen extends ConsumerStatefulWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _simulate = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(homeControllerProvider);
    // Fix for specs.json Block #3 (StealthConfig has no consumers):
    // when stealth is enabled, render the fake name instead of the
    // "Guardian Angela" branded title, with the fake-icon preset
    // surfaced as a subtitle so the disguise reads coherently.
    final stealth =
        ref.watch(settingsControllerProvider).value?.defaults.stealth;
    final useStealth = stealth != null && stealth.enabled;
    final title = useStealth ? stealth.fakeName : l.homeTitle;
    final subtitle = useStealth ? stealth.fakeIcon.name : null;
    return Scaffold(
      appBar: AppBar(
        title: subtitle == null
            ? Text(title)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l.homeMenuSettings,
            onPressed: () => context.push(RouteNames.settings),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('$err')),
        data: (data) => _HomeBody(
          state: data,
          simulate: _simulate,
          onSimulateChanged: (v) => setState(() => _simulate = v),
        ),
      ),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({
    required this.state,
    required this.simulate,
    required this.onSimulateChanged,
  });

  final HomeState state;
  final bool simulate;
  final ValueChanged<bool> onSimulateChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final mode = state.selectedMode;
    final active = state.activeSession;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (active != null) ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.shield),
                title: Text(l.homeActiveSession),
                subtitle: Text(active.modeId),
                onTap: () => context.push(RouteNames.session),
                trailing: FilledButton(
                  onPressed: () => context.push(RouteNames.session),
                  child: Text(l.homeResumeSession),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (state.modes.isEmpty)
            Text(l.homeNoModes)
          else
            DropdownButtonFormField<String>(
              initialValue: mode?.id,
              decoration: InputDecoration(labelText: l.homeSelectMode),
              items: [
                for (final m in state.modes)
                  DropdownMenuItem(value: m.id, child: Text(m.name)),
              ],
              onChanged: (id) {
                if (id != null) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setSelectedModeId(id);
                }
              },
            ),
          const SizedBox(height: 24),
          SwitchListTile(
            value: simulate,
            onChanged: onSimulateChanged,
            title: Text(l.homeSimulate),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: Text(l.homeStartSession),
            onPressed: mode == null || active != null
                ? null
                : () async {
                    await ref
                        .read(sessionControllerProvider.notifier)
                        .startSession(modeId: mode.id, isSimulation: simulate);
                    if (context.mounted) {
                      context.push(RouteNames.session);
                    }
                  },
          ),
          const SizedBox(height: 8),
          if (state.contacts.isEmpty) Text(l.homeNoContacts),
          const Spacer(),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: 8,
            runSpacing: 8,
            children: [
              _HomeShortcut(
                icon: Icons.contacts,
                label: l.homeMenuContacts,
                route: RouteNames.contacts,
              ),
              _HomeShortcut(
                icon: Icons.tune,
                label: l.homeMenuModes,
                route: RouteNames.modes,
              ),
              _HomeShortcut(
                icon: Icons.history,
                label: l.homeMenuHistory,
                route: RouteNames.pastEvents,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeShortcut extends StatelessWidget {
  const _HomeShortcut({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: () => context.push(route),
    icon: Icon(icon),
    label: Text(label),
  );
}
