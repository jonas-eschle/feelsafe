import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/core/theme/guardian_angela_logo.dart';
import 'package:guardianangela/core/widgets/pride_page_indicator.dart';
import 'package:guardianangela/features/onboarding/onboarding_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// First-launch onboarding flow (3 pages).
///
/// See spec 04 §Onboarding Flow. Navigation uses a [PageController] and
/// Next/Back buttons. The "Get started" button on the final page marks
/// `AppSettings.isFirstLaunch = false` and routes to `/`.
class OnboardingScreen extends ConsumerStatefulWidget {
  /// Creates an [OnboardingScreen].
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    setState(() => _page = page);
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _finish() async {
    await ref.read(onboardingControllerProvider.notifier).completeOnboarding();
    if (!mounted) return;
    context.goNamed(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (int p) => setState(() => _page = p),
                children: const <Widget>[
                  _WelcomePage(),
                  _ProfileContactPage(),
                  _PermissionsPage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  PridePageIndicator(currentIndex: _page, pageCount: 3),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TextButton(
                        onPressed: _page == 0 ? null : () => _goTo(_page - 1),
                        child: Text(l10n.commonBack),
                      ),
                      if (_page < 2)
                        FilledButton(
                          onPressed: () => _goTo(_page + 1),
                          child: Text(l10n.onboardingNext),
                        )
                      else
                        FilledButton(
                          onPressed: _finish,
                          child: Text(l10n.onboardingGetStarted),
                        ),
                    ],
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

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const GuardianAngelaLogo(size: 120),
          const SizedBox(height: 24),
          Text(
            l10n.onboardingWelcomeGreeting,
            style: textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingWelcomeBodyFull,
            style: textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.homeTagline,
            style: textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProfileContactPage extends ConsumerStatefulWidget {
  const _ProfileContactPage();

  @override
  ConsumerState<_ProfileContactPage> createState() =>
      _ProfileContactPageState();
}

class _ProfileContactPageState extends ConsumerState<_ProfileContactPage> {
  final TextEditingController _nameCtl = TextEditingController();
  final TextEditingController _phoneCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingControllerProvider);
    _nameCtl.text = state.draftName ?? '';
    _phoneCtl.text = state.draftPhone ?? '';
    _nameCtl.addListener(_persist);
    _phoneCtl.addListener(_persist);
  }

  void _persist() {
    ref
        .read(onboardingControllerProvider.notifier)
        .updateProfileDraft(name: _nameCtl.text, phone: _phoneCtl.text);
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _phoneCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(onboardingControllerProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(l10n.onboardingProfileTitle, style: textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtl,
              decoration: InputDecoration(
                labelText: l10n.onboardingProfileNameLabel,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneCtl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: l10n.onboardingProfilePhoneLabel,
                helperText: l10n.onboardingProfilePhoneHelper,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.onboardingEmergencyContactHeader,
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(l10n.onboardingEmergencyContactPrompt),
            const SizedBox(height: 12),
            if (state.contactCount == 0)
              OutlinedButton.icon(
                icon: const Icon(Icons.person_add_alt),
                label: Text(l10n.onboardingEmergencyContactAdd),
                onPressed: () => context.pushNamed(RouteNames.contactForm),
              )
            else
              Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(
                    '${state.contactCount} '
                    '${l10n.onboardingEmergencyContactHeader.toLowerCase()}',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PermissionsPage extends ConsumerWidget {
  const _PermissionsPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              l10n.onboardingPermissionsTitle,
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(l10n.onboardingPermissionsIntro),
            const SizedBox(height: 16),
            _PermissionTile(
              label: l10n.homePermissionsNotification,
              description: l10n.onboardingPermissionsNotificationDesc,
              isRequired: true,
            ),
            _PermissionTile(
              label: l10n.homePermissionsSendSms,
              description: l10n.onboardingPermissionsSmsDesc,
              isRequired: true,
            ),
            _PermissionTile(
              label: l10n.homePermissionsCallPhone,
              description: l10n.onboardingPermissionsPhoneDesc,
              isRequired: true,
            ),
            _PermissionTile(
              label: l10n.homePermissionsLocation,
              description: l10n.onboardingPermissionsLocationDesc,
              isRequired: true,
            ),
            _PermissionTile(
              label: l10n.onboardingPermissionsMicrophone,
              description: l10n.onboardingPermissionsMicrophoneDesc,
              isRequired: false,
            ),
            _PermissionTile(
              label: l10n.onboardingPermissionsCamera,
              description: l10n.onboardingPermissionsCameraDesc,
              isRequired: false,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref
                  .read(onboardingControllerProvider.notifier)
                  .requestAllPermissions(),
              child: Text(l10n.onboardingPermissionsGrantAll),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.label,
    required this.description,
    required this.isRequired,
  });

  final String label;
  final String description;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: ListTile(
        title: Text(label),
        subtitle: Text(description),
        trailing: Chip(
          label: Text(
            isRequired
                ? l10n.onboardingPermissionsRequired
                : l10n.onboardingPermissionsOptional,
          ),
        ),
      ),
    );
  }
}
