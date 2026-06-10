import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:guardianangela/data/repositories/contacts_repository.dart';
import 'package:guardianangela/services/app_state_providers.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Immutable in-progress state for the onboarding flow.
@immutable
class OnboardingState {
  /// Creates an [OnboardingState].
  const OnboardingState({
    this.draftName,
    this.draftPhone,
    this.contactCount = 0,
  });

  /// Draft name entered on the profile page.
  final String? draftName;

  /// Draft phone number entered on the profile page.
  final String? draftPhone;

  /// Number of contacts already saved (live-updated from the repo).
  final int contactCount;

  /// Returns a copy with the listed fields replaced.
  OnboardingState copyWith({
    String? draftName,
    String? draftPhone,
    int? contactCount,
  }) => OnboardingState(
    draftName: draftName ?? this.draftName,
    draftPhone: draftPhone ?? this.draftPhone,
    contactCount: contactCount ?? this.contactCount,
  );
}

/// Onboarding controller.
///
/// Holds the profile draft in memory until the user taps "Get started",
/// at which point [completeOnboarding] persists the draft + flips the
/// `AppSettings.isFirstLaunch` flag.
class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    _watchContacts();
    return const OnboardingState();
  }

  void _watchContacts() {
    Future<void>.microtask(() async {
      try {
        final db = await ref.read(databaseProvider.future);
        final list = await ContactsRepository(db.contactsDao).getAll();
        if (ref.mounted) {
          state = state.copyWith(contactCount: list.length);
        }
      } catch (_) {
        // Empty / loading database is acceptable during onboarding;
        // contactCount stays at 0.
      }
    });
  }

  /// Updates the in-memory profile draft.
  void updateProfileDraft({String? name, String? phone}) {
    state = state.copyWith(draftName: name, draftPhone: phone);
  }

  /// Requests every onboarding permission in sequence.
  ///
  /// Uses `package:permission_handler` directly because the OS prompts
  /// are user-driven and have no engine side effects. Failures are
  /// silently swallowed — the home checklist re-prompts as needed.
  Future<void> requestAllPermissions() async {
    const requested = <Permission>[
      Permission.notification,
      Permission.sms,
      Permission.phone,
      Permission.location,
      Permission.microphone,
      Permission.camera,
    ];
    try {
      await requested.request();
    } catch (_) {
      // Non-fatal: the user can re-request from the home checklist.
    }
  }

  /// Persists draft profile + sets `isFirstLaunch = false`.
  Future<void> completeOnboarding() async {
    final settingsRepo = ref.read(appSettingsRepositoryProvider);
    final profileRepo = ref.read(userProfileRepositoryProvider);

    final settings = await settingsRepo.load();
    await settingsRepo.save(settings.copyWith(isFirstLaunch: false));
    // The router's first-launch redirect reads the keep-alive
    // [firstLaunchProvider], whose cache still holds the `true` that routed
    // the user here. Invalidate AND await the re-load so the redirect sees
    // `false` before `OnboardingScreen._finish` navigates home — invalidate
    // alone keeps exposing the previous value until the new future
    // resolves, which would bounce the navigation back to /onboarding.
    ref.invalidate(firstLaunchProvider);
    await ref.read(firstLaunchProvider.future);

    final profile = await profileRepo.load();
    final updated = profile.copyWith(
      name: state.draftName?.trim().isEmpty ?? true ? null : state.draftName,
      phoneNumber: state.draftPhone?.trim().isEmpty ?? true
          ? null
          : state.draftPhone,
    );
    await profileRepo.save(updated);
  }
}

/// Provides [OnboardingController].
final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );
