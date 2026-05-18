/// Profile-feature controller.
///
/// Exposes the single [UserProfile] row. Returns `null` when the
/// user has not completed onboarding yet (so UI can branch on the
/// absence).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';

/// Async controller exposing the user profile.
class ProfileController extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    final repo = ref.read(userProfileRepositoryProvider);
    return repo.get();
  }

  /// Overwrites the persisted profile with [profile].
  Future<void> save(UserProfile profile) async {
    final repo = ref.read(userProfileRepositoryProvider);
    await repo.save(profile);
    state = AsyncValue.data(profile);
  }

  /// Forces a reload from the repository.
  Future<void> reload() async {
    state = const AsyncValue.loading();
    final repo = ref.read(userProfileRepositoryProvider);
    state = AsyncValue.data(await repo.get());
  }
}

/// Provider for `ProfileController`.
final AsyncNotifierProvider<ProfileController, UserProfile?>
profileControllerProvider =
    AsyncNotifierProvider<ProfileController, UserProfile?>(
      ProfileController.new,
    );
