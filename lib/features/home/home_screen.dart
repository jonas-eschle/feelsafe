import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/pride_widgets.dart';
import '../../data/models/session_mode.dart';
import '../../l10n/app_localizations.dart';
import '../contacts/contacts_controller.dart';
import '../modes/modes_controller.dart';
import '../session/session_controller.dart';
import '../settings/settings_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedModeId;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final modesAsync = ref.watch(modesControllerProvider);
    final settingsAsync = ref.watch(settingsControllerProvider);
    final contactsAsync = ref.watch(contactsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        bottom: const PrideAppBarBottom(),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => context.push(RouteNames.contacts),
            tooltip: l10n.emergencyContacts,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(RouteNames.settings),
            tooltip: l10n.settings,
          ),
        ],
      ),
      body: modesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (modes) {
          // Initialize selected mode from settings if not set
          if (_selectedModeId == null && modes.isNotEmpty) {
            final settingsId = settingsAsync.valueOrNull?.selectedModeId;
            _selectedModeId = settingsId ?? modes.first.id;
          }

          final selectedMode =
              modes.where((m) => m.id == _selectedModeId).firstOrNull;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Shield icon with pride gradient circle behind it
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.prideGradientSubtle,
                  ),
                  child: const Icon(
                    Icons.shield,
                    size: 56,
                    color: AppColors.safe,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.appTitle,
                  style: theme.textTheme.headlineLarge,
                ),
                const Spacer(),
                // Mode selector
                Text(l10n.modes, style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                _ModeSelector(
                  modes: modes,
                  selectedId: _selectedModeId,
                  onSelected: (id) {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedModeId = id);
                    ref
                        .read(settingsControllerProvider.notifier)
                        .setSelectedModeId(id);
                  },
                ),
                const SizedBox(height: 24),
                // Contact chips
                contactsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (contacts) {
                    if (contacts.isEmpty) {
                      return TextButton.icon(
                        onPressed: () => context.push(RouteNames.contacts),
                        icon: const Icon(Icons.add, size: 16),
                        label: Text(l10n.addContact),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.warning,
                        ),
                      );
                    }
                    return Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      alignment: WrapAlignment.center,
                      children: contacts.take(5).map((contact) {
                        return Chip(
                          avatar: CircleAvatar(
                            radius: 12,
                            child: Text(
                              contact.name.isNotEmpty
                                  ? contact.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                          label: Text(
                            contact.name,
                            style: theme.textTheme.bodySmall,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    );
                  },
                ),
                const Spacer(),
                // Animated start button with glow
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final glow = _pulseController.value * 0.4;
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.safe.withValues(alpha: glow),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: FilledButton.icon(
                      onPressed: selectedMode != null
                          ? () => _startSession(selectedMode)
                          : null,
                      icon: const Icon(Icons.shield, size: 28),
                      label: Text(
                        l10n.startSession,
                        style: const TextStyle(fontSize: 20),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.safe,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _startSession(SessionMode mode) async {
    HapticFeedback.heavyImpact();
    await ref.read(sessionControllerProvider.notifier).startSession(mode);
    if (mounted) {
      context.push(RouteNames.session);
    }
  }
}

class _ModeSelector extends StatelessWidget {
  final List<SessionMode> modes;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  const _ModeSelector({
    required this.modes,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: modes.map((mode) {
        final isSelected = mode.id == selectedId;
        final icon = mode.checkInMechanism == CheckInMechanism.holdButton
            ? Icons.directions_walk
            : Icons.restaurant;
        final label = mode.isBuiltIn
            ? (mode.checkInMechanism == CheckInMechanism.holdButton
                ? l10n.walkMode
                : l10n.dateMode)
            : mode.name;

        return ChoiceChip(
          avatar: Icon(icon, size: 18),
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => onSelected(mode.id),
          selectedColor: AppColors.safe.withValues(alpha: 0.3),
        );
      }).toList(),
    );
  }
}
