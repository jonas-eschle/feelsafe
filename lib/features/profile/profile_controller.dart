import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import 'package:guardianangela/domain/models/user_profile.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Immutable state for the profile screen.
@immutable
class ProfileState {
  /// Creates a [ProfileState].
  const ProfileState({required this.profile});

  /// Current user profile.
  final UserProfile profile;
}

/// Controller for the profile editor.
class ProfileController extends AsyncNotifier<ProfileState> {
  @override
  Future<ProfileState> build() async {
    final repo = ref.read(userProfileRepositoryProvider);
    final profile = await repo.load();
    return ProfileState(profile: profile);
  }

  /// Patches the profile with the supplied non-null fields.
  Future<void> patch({
    String? name,
    int? age,
    String? phoneNumber,
    String? photoPath,
    String? physicalDescription,
    String? bloodType,
    String? allergies,
    String? medications,
    String? medicalConditions,
    String? emergencyInstructions,
  }) async {
    final current = state.value;
    if (current == null) return;
    final repo = ref.read(userProfileRepositoryProvider);
    final updated = current.profile.copyWith(
      name: name,
      age: age,
      phoneNumber: phoneNumber,
      photoPath: photoPath,
      physicalDescription: physicalDescription,
      bloodType: bloodType,
      allergies: allergies,
      medications: medications,
      medicalConditions: medicalConditions,
      emergencyInstructions: emergencyInstructions,
    );
    await repo.save(updated);
    state = AsyncData(ProfileState(profile: updated));
  }
}

/// Provides [ProfileController].
final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, ProfileState>(
      ProfileController.new,
    );
