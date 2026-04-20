/// App entry point.
///
/// Initializes the Flutter binding, wraps the app in a
/// `ProviderScope`, and hands off to `GuardianAngelaApp`.
library;

import 'package:flutter/widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/app.dart';

export 'package:guardianangela/app.dart' show GuardianAngelaApp;

/// Main entry point.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO Phase 6: init AppDatabase before runApp.
  runApp(const ProviderScope(child: GuardianAngelaApp()));
}
