import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/app.dart';

void main() {
  testWidgets('GuardianAngelaApp builds without throwing', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: GuardianAngelaApp()));
    await tester.pump();
    expect(find.byType(GuardianAngelaApp), findsOneWidget);
  });
}
