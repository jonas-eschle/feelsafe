import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/main.dart';

void main() {
  testWidgets('GuardianAngelaApp renders a Placeholder', (tester) async {
    await tester.pumpWidget(const GuardianAngelaApp());
    expect(find.byType(Placeholder), findsOneWidget);
  });
}
