/// Onboarding flow.
///
/// Three pages: Welcome, Profile+Contact, Permissions. The last page
/// invokes `onboardingController.completeOnboarding()` and navigates
/// to the home route.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/core/theme/guardian_angela_logo.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/user_profile.dart';
import 'package:guardianangela/features/contacts/contacts_controller.dart';
import 'package:guardianangela/features/onboarding/onboarding_controller.dart';
import 'package:guardianangela/features/profile/profile_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// First-launch onboarding flow.
class OnboardingScreen extends ConsumerStatefulWidget {
  /// Creates the onboarding screen.
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _contactNameCtrl = TextEditingController();
  final TextEditingController _contactPhoneCtrl = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _nameCtrl.dispose();
    _contactNameCtrl.dispose();
    _contactPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final name = _nameCtrl.text.trim();
    if (name.isNotEmpty) {
      await ref
          .read(profileControllerProvider.notifier)
          .save(UserProfile(name: name));
    }
    final contactName = _contactNameCtrl.text.trim();
    final contactPhone = _contactPhoneCtrl.text.trim();
    if (contactName.isNotEmpty && contactPhone.isNotEmpty) {
      await ref
          .read(contactsControllerProvider.notifier)
          .save(
            EmergencyContact(
              id: const Uuid().v4(),
              name: contactName,
              phoneNumber: contactPhone,
              sortOrder: 0,
              channels: const [MessageChannel.sms],
            ),
          );
    }
    await ref.read(onboardingControllerProvider.notifier).completeOnboarding();
    if (mounted) context.go(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  const _WelcomePage(),
                  _ProfilePage(
                    nameCtrl: _nameCtrl,
                    contactNameCtrl: _contactNameCtrl,
                    contactPhoneCtrl: _contactPhoneCtrl,
                  ),
                  const _PermissionsPage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  TextButton(onPressed: _finish, child: Text(l.onboardingSkip)),
                  const Spacer(),
                  for (var i = 0; i < 3; i++)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _page
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).disabledColor,
                      ),
                    ),
                  const Spacer(),
                  if (_page < 2)
                    FilledButton(
                      onPressed: () => _controller.nextPage(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOut,
                      ),
                      child: Text(l.onboardingNext),
                    )
                  else
                    FilledButton(
                      onPressed: _finish,
                      child: Text(l.onboardingFinish),
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
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const GuardianAngelaLogo(size: 144),
          const SizedBox(height: 32),
          Text(
            l.onboardingWelcomeTitle,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l.onboardingWelcomeBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage({
    required this.nameCtrl,
    required this.contactNameCtrl,
    required this.contactPhoneCtrl,
  });

  final TextEditingController nameCtrl;
  final TextEditingController contactNameCtrl;
  final TextEditingController contactPhoneCtrl;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.onboardingProfileTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(l.onboardingProfileBody),
          const SizedBox(height: 24),
          TextField(
            controller: nameCtrl,
            decoration: InputDecoration(labelText: l.profileFieldName),
          ),
          const SizedBox(height: 16),
          Text(l.contactsTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: contactNameCtrl,
            decoration: InputDecoration(labelText: l.contactFieldName),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: contactPhoneCtrl,
            decoration: InputDecoration(labelText: l.contactFieldPhone),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }
}

class _PermissionsPage extends StatelessWidget {
  const _PermissionsPage();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_open, size: 96),
          const SizedBox(height: 24),
          Text(
            l.onboardingPermissionsTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(l.onboardingPermissionsBody, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
