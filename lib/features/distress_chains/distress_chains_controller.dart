/// Distress-chains feature controller stub.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/domain/models/models.dart';

/// Stub AsyncNotifier exposing the list of global distress chains.
class DistressChainsController extends AsyncNotifier<List<DistressChain>> {
  @override
  Future<List<DistressChain>> build() async => const <DistressChain>[];
}

/// Provider for `DistressChainsController`.
final AsyncNotifierProvider<DistressChainsController, List<DistressChain>>
    distressChainsControllerProvider =
    AsyncNotifierProvider<DistressChainsController, List<DistressChain>>(
  DistressChainsController.new,
);
