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
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/permissions/required_permissions.dart';
import 'package:guardianangela/features/home/home_controller.dart';
import 'package:guardianangela/features/modes/widgets/mode_icon_library.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Landing screen for returning users.
class HomeScreen extends ConsumerWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        data: (data) => _HomeBody(state: data),
      ),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({required this.state});

  final HomeState state;

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
          _ContactBanner(contactCount: state.contacts.length),
          if (state.contacts.isEmpty) ...[
            const SizedBox(height: 4),
            Text(l.homeNoContacts),
          ],
          const SizedBox(height: 16),
          if (state.modes.isEmpty)
            Text(l.homeNoModes)
          else
            for (final m in state.modes)
              Card(
                child: InkWell(
                  onTap: () => ref
                      .read(settingsControllerProvider.notifier)
                      .setSelectedModeId(m.id),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Issues-v4 #12 — prefer the user-selected
                        // mode icon (from the mode-editor picker).
                        // Fall back to the legacy name-heuristic for
                        // unnamed user modes that pre-date the
                        // iconName field.
                        Icon(
                          iconForName(m.iconName) ?? _iconForModeName(m.name),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(m.name)),
                        if (mode?.id == m.id)
                          const Icon(Icons.check_circle),
                      ],
                    ),
                  ),
                ),
              ),
          const SizedBox(height: 16),
          // Spec 04 §Selected Mode Card: the Start + Simulate buttons
          // belong to the selected-mode card, which is itself gated
          // on at least one configured mode. With zero modes, the
          // card isn't rendered. With modes but no active session,
          // Start is disabled if nothing is selected; Simulate is
          // disabled when a session is already running.
          if (state.modes.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: Text(l.homeStartSession),
                    onPressed: (mode == null || active != null)
                        ? null
                        : () => _onStart(
                              context: context,
                              ref: ref,
                              mode: mode,
                              isSimulation: false,
                              l: l,
                            ),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  icon: const Icon(Icons.science_outlined),
                  label: Text(l.homeSimulate),
                  onPressed: (mode == null || active != null)
                      ? null
                      : () => _onStart(
                            context: context,
                            ref: ref,
                            mode: mode,
                            isSimulation: true,
                            l: l,
                          ),
                ),
              ],
            ),
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

/// Picks a mode-specific icon based on the mode name. Used by the
/// mode tile in [HomeScreen]. Falls back to `tune` for unknown
/// names so every tile gets a visual; `shield` is reserved for the
/// active-session card so the two never collide.
IconData _iconForModeName(String name) {
  final n = name.toLowerCase();
  if (n.contains('walk')) return Icons.directions_walk;
  if (n.contains('date')) return Icons.favorite;
  if (n.contains('run')) return Icons.directions_run;
  if (n.contains('bike') || n.contains('cycle')) {
    return Icons.directions_bike;
  }
  if (n.contains('night')) return Icons.nightlight_round;
  return Icons.tune;
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

class _ContactBanner extends StatelessWidget {
  const _ContactBanner({required this.contactCount});

  /// Number of configured emergency contacts.
  final int contactCount;

  @override
  Widget build(BuildContext context) {
    if (contactCount > 0) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline),
          const SizedBox(width: 8),
          Expanded(child: Text(l.homeContactsBannerNone)),
        ],
      ),
    );
  }
}

Future<void> _onStart({
  required BuildContext context,
  required WidgetRef ref,
  required SessionMode mode,
  required bool isSimulation,
  required AppLocalizations l,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.homeStartConfirmTitle),
      content: Text(l.homeStartConfirmBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(l.homeStartSession),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  if (!context.mounted) return;
  // Pre-flight permission audit: only the perms THIS mode's chain
  // actually needs are requested, and only the ones that aren't
  // already granted will show a system dialog. Skipped in
  // simulation mode because no real side effects are triggered.
  if (!isSimulation) {
    final denied = await ensureSessionPermissions(
      service: ref.read(permissionServiceProvider),
      mode: mode,
    );
    if (denied.isNotEmpty) {
      if (!context.mounted) return;
      final proceed = await _showMissingPermissionsDialog(
        context: context,
        denied: denied,
        l: l,
      );
      if (proceed != true) return;
    }
    if (!context.mounted) return;
  }
  await ref
      .read(sessionControllerProvider.notifier)
      .startSession(modeId: mode.id, isSimulation: isSimulation);
  if (context.mounted) {
    context.push(RouteNames.session);
  }
}

Future<bool?> _showMissingPermissionsDialog({
  required BuildContext context,
  required Set<RequiredPermission> denied,
  required AppLocalizations l,
}) {
  final lines = denied.map((p) => '• ${_labelFor(p, l)}').join('\n');
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.homePermissionsMissingTitle),
      content: Text('${l.homePermissionsMissingBody}\n\n$lines'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(l.homePermissionsContinueAnyway),
        ),
      ],
    ),
  );
}

String _labelFor(RequiredPermission p, AppLocalizations l) => switch (p) {
  RequiredPermission.notification => l.homePermissionsNotification,
  RequiredPermission.location => l.homePermissionsLocation,
  RequiredPermission.callPhone => l.homePermissionsCallPhone,
  RequiredPermission.sendSms => l.homePermissionsSendSms,
};
