import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_names.dart';
import '../../core/permissions/permission_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/pride_widgets.dart';
import '../../data/models/emergency_contact.dart';
import '../../data/models/session_mode.dart';
import '../../l10n/app_localizations.dart';
import '../contacts/contacts_controller.dart';
import '../modes/modes_controller.dart';
import '../settings/settings_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  static const _pageCount = 5;

  // Contact form state
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  MessageChannel _preferredChannel = MessageChannel.sms;

  // Mode selection state
  String? _selectedModeId;

  // Emergency number state
  late final TextEditingController _emergencyNumberController;

  // Permission state
  Map<String, bool> _permissions = {};

  @override
  void initState() {
    super.initState();
    // Default emergency number based on platform locale
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    final langCode = locale.languageCode;
    final defaultNumber =
        const {'de', 'fr', 'es', 'ru'}.contains(langCode) ? '112' : '911';
    _emergencyNumberController = TextEditingController(text: defaultNumber);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emergencyNumberController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finish() async {
    // Save contact if form is filled
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isNotEmpty && phone.isNotEmpty) {
      await ref.read(contactsControllerProvider.notifier).addContact(
            name: name,
            phoneNumber: phone,
            preferredChannel: _preferredChannel,
          );
    }

    // Save selected mode
    if (_selectedModeId != null) {
      await ref
          .read(settingsControllerProvider.notifier)
          .setSelectedModeId(_selectedModeId);
    }

    // Save emergency number
    final emergencyNum = _emergencyNumberController.text.trim();
    if (emergencyNum.isNotEmpty) {
      await ref
          .read(settingsControllerProvider.notifier)
          .setEmergencyNumber(emergencyNum);
    }

    // Mark onboarding complete
    await ref.read(settingsControllerProvider.notifier).markOnboardingComplete();

    if (mounted) {
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Pride page indicator + Skip button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                children: [
                  const SizedBox(width: 60), // balance the skip button
                  Expanded(
                    child: PridePageIndicator(
                      count: _pageCount,
                      current: _currentPage,
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: (_currentPage < _pageCount - 1)
                        ? TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.skipStepWarning),
                                ),
                              );
                              _nextPage();
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                            child: Text(l10n.skipStep),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _WelcomePage(l10n: l10n),
                  _ModeSelectionPage(
                    l10n: l10n,
                    selectedModeId: _selectedModeId,
                    onModeSelected: (id) =>
                        setState(() => _selectedModeId = id),
                  ),
                  _AddContactPage(
                    l10n: l10n,
                    nameController: _nameController,
                    phoneController: _phoneController,
                    preferredChannel: _preferredChannel,
                    onChannelChanged: (ch) =>
                        setState(() => _preferredChannel = ch),
                  ),
                  _EmergencyNumberPage(
                    l10n: l10n,
                    controller: _emergencyNumberController,
                  ),
                  _PermissionsPage(
                    l10n: l10n,
                    permissions: _permissions,
                    onPermissionsUpdated: (p) =>
                        setState(() => _permissions = p),
                  ),
                ],
              ),
            ),
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _previousPage,
                      child: Text(l10n.onboardingBack),
                    )
                  else
                    const SizedBox(width: 80),
                  const Spacer(),
                  if (_currentPage < _pageCount - 1)
                    FilledButton(
                      onPressed: _nextPage,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.safe,
                      ),
                      child: Text(l10n.onboardingNext),
                    )
                  else
                    FilledButton(
                      onPressed: _finish,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.safe,
                      ),
                      child: Text(l10n.onboardingGetStarted),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -- Page 1: Welcome --

class _WelcomePage extends StatelessWidget {
  final AppLocalizations l10n;

  const _WelcomePage({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.prideGradientSubtle,
            ),
            child: const Icon(Icons.shield, size: 72, color: AppColors.safe),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.onboardingWelcome,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingDescription,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// -- Page 2: Mode Selection --

class _ModeSelectionPage extends ConsumerWidget {
  final AppLocalizations l10n;
  final String? selectedModeId;
  final ValueChanged<String> onModeSelected;

  const _ModeSelectionPage({
    required this.l10n,
    required this.selectedModeId,
    required this.onModeSelected,
  });

  void _createCustomMode(BuildContext context) {
    context.go(RouteNames.modeEdit);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final modesAsync = ref.watch(modesControllerProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.onboardingSelectMode,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingSelectModeDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          modesAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('$e'),
            data: (modes) {
              final effectiveSelected =
                  selectedModeId ?? (modes.isNotEmpty ? modes.first.id : null);
              return Column(
                children: [
                  ...modes.map((mode) {
                    final isSelected = mode.id == effectiveSelected;
                    final icon =
                        mode.checkInMechanism == CheckInMechanism.holdButton
                            ? Icons.directions_walk
                            : Icons.restaurant;
                    final label = mode.isBuiltIn
                        ? (mode.checkInMechanism == CheckInMechanism.holdButton
                            ? l10n.walkMode
                            : l10n.dateMode)
                        : mode.name;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: isSelected
                            ? AppColors.safe.withValues(alpha: 0.15)
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => onModeSelected(mode.id),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: isSelected
                                  ? Border.all(
                                      color: AppColors.safe, width: 2)
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(icon, size: 32, color: AppColors.safe),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    label,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.safe,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  OutlinedButton.icon(
                    onPressed: () => _createCustomMode(context),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.createCustomMode),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// -- Page 3: Add Contact --

class _AddContactPage extends StatelessWidget {
  final AppLocalizations l10n;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final MessageChannel preferredChannel;
  final ValueChanged<MessageChannel> onChannelChanged;

  const _AddContactPage({
    required this.l10n,
    required this.nameController,
    required this.phoneController,
    required this.preferredChannel,
    required this.onChannelChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Text(
            l10n.onboardingAddContact,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingAddContactDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: l10n.contactName,
              prefixIcon: const Icon(Icons.person),
              border: const OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: phoneController,
            decoration: InputDecoration(
              labelText: l10n.contactPhone,
              prefixIcon: const Icon(Icons.phone),
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 16),
          SegmentedButton<MessageChannel>(
            segments: [
              ButtonSegment(
                value: MessageChannel.sms,
                label: Text(l10n.sms),
                icon: const Icon(Icons.sms),
              ),
              ButtonSegment(
                value: MessageChannel.whatsapp,
                label: Text(l10n.whatsapp),
                icon: const Icon(Icons.chat),
              ),
              ButtonSegment(
                value: MessageChannel.telegram,
                label: Text(l10n.telegram),
                icon: const Icon(Icons.send),
              ),
              ButtonSegment(
                value: MessageChannel.phoneCall,
                label: Text(l10n.phoneCall),
                icon: const Icon(Icons.phone),
              ),
            ],
            selected: {preferredChannel},
            onSelectionChanged: (set) => onChannelChanged(set.first),
          ),
        ],
      ),
    );
  }
}

// -- Page 4: Emergency Number --

class _EmergencyNumberPage extends StatelessWidget {
  final AppLocalizations l10n;
  final TextEditingController controller;

  const _EmergencyNumberPage({
    required this.l10n,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emergency, size: 64, color: AppColors.safe),
          const SizedBox(height: 24),
          Text(
            l10n.emergencyNumberSetup,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.emergencyNumberDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: l10n.emergencyNumber,
              prefixIcon: const Icon(Icons.phone),
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }
}

// -- Page 5: Permissions --

class _PermissionsPage extends StatefulWidget {
  final AppLocalizations l10n;
  final Map<String, bool> permissions;
  final ValueChanged<Map<String, bool>> onPermissionsUpdated;

  const _PermissionsPage({
    required this.l10n,
    required this.permissions,
    required this.onPermissionsUpdated,
  });

  @override
  State<_PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<_PermissionsPage> {
  final _permissionService = PermissionService();
  bool _requesting = false;

  Future<void> _requestPermissions() async {
    setState(() => _requesting = true);
    final results = await _permissionService.requestEssentialPermissions();
    widget.onPermissionsUpdated(results);
    setState(() => _requesting = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = widget.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.security, size: 64, color: AppColors.safe),
          const SizedBox(height: 24),
          Text(
            l10n.onboardingPermissions,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingPermissionsDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Permission status list
          if (widget.permissions.isNotEmpty) ...[
            _PermissionRow(
              label: l10n.permissionLocation,
              icon: Icons.location_on,
              granted: widget.permissions['location'] ?? false,
              l10n: l10n,
            ),
            _PermissionRow(
              label: l10n.permissionPhone,
              icon: Icons.phone,
              granted: widget.permissions['phone'] ?? false,
              l10n: l10n,
            ),
            if (Platform.isAndroid)
              _PermissionRow(
                label: l10n.permissionSms,
                icon: Icons.sms,
                granted: widget.permissions['sms'] ?? false,
                l10n: l10n,
              ),
            const SizedBox(height: 24),
          ],
          FilledButton.icon(
            onPressed: _requesting ? null : _requestPermissions,
            icon: _requesting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check),
            label: Text(l10n.grantPermissions),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.safe,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool granted;
  final AppLocalizations l10n;

  const _PermissionRow({
    required this.label,
    required this.icon,
    required this.granted,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: granted ? AppColors.safe : AppColors.warning),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
          Text(
            granted ? l10n.permissionGranted : l10n.permissionDenied,
            style: TextStyle(
              color: granted ? AppColors.safe : AppColors.warning,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
