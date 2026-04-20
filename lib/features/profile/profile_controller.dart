/// Profile-feature controller stub.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardianangela/domain/models/models.dart';

/// Stub AsyncNotifier exposing the single user profile; nullable.
class ProfileController extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async => null;
}

/// Provider for `ProfileController`.
final AsyncNotifierProvider<ProfileController, UserProfile?>
    profileControllerProvider =
    AsyncNotifierProvider<ProfileController, UserProfile?>(
  ProfileController.new,
);
