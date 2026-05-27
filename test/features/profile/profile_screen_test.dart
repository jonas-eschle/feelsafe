/// Widget tests for [ProfileScreen].
///
/// Follows the reference pattern from
/// `test/features/home/home_screen_test.dart`:
/// 1. [_FakeProfileController] subclasses [ProfileController] and
///    overrides `build()` to return a canned [ProfileState].
/// 2. Each test calls `pumpScreen(tester, const ProfileScreen(), …)`.
/// 3. Assertions use `find.byType`, `find.text`, l10n keys, and
///    call-count tracking on the fake.
///
/// Spec ref: `docs/spec/04-screens-navigation.md §Profile Editor`.
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/models/user_profile.dart';
import 'package:guardianangela/features/profile/profile_controller.dart';
import 'package:guardianangela/features/profile/profile_screen.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Test fake
// ---------------------------------------------------------------------------

class _FakeProfileController extends ProfileController {
  _FakeProfileController(this._initial);

  final ProfileState _initial;

  // Track patch calls.
  int patchCalls = 0;
  String? lastPatchedName;
  String? lastPatchedPhone;
  int? lastPatchedAge;
  String? lastPatchedBloodType;
  String? lastPatchedAllergies;
  String? lastPatchedMedications;
  String? lastPatchedConditions;
  String? lastPatchedInstructions;
  String? lastPatchedDescription;

  @override
  Future<ProfileState> build() async => _initial;

  @override
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
    patchCalls++;
    if (name != null) lastPatchedName = name;
    if (phoneNumber != null) lastPatchedPhone = phoneNumber;
    if (age != null) lastPatchedAge = age;
    if (bloodType != null) lastPatchedBloodType = bloodType;
    if (allergies != null) lastPatchedAllergies = allergies;
    if (medications != null) lastPatchedMedications = medications;
    if (medicalConditions != null) lastPatchedConditions = medicalConditions;
    if (emergencyInstructions != null) {
      lastPatchedInstructions = emergencyInstructions;
    }
    if (physicalDescription != null) {
      lastPatchedDescription = physicalDescription;
    }

    final current = state.value;
    if (current == null) return;
    final updated = current.profile.copyWith(
      name: name,
      age: age,
      phoneNumber: phoneNumber,
      physicalDescription: physicalDescription,
      bloodType: bloodType,
      allergies: allergies,
      medications: medications,
      medicalConditions: medicalConditions,
      emergencyInstructions: emergencyInstructions,
    );
    state = AsyncData(ProfileState(profile: updated));
  }
}

// ---------------------------------------------------------------------------
// Test data factories
// ---------------------------------------------------------------------------

ProfileState _emptyState() => const ProfileState(profile: UserProfile());

ProfileState _populatedState() => const ProfileState(
  profile: UserProfile(
    name: 'Alice',
    age: 30,
    phoneNumber: '+15550100',
    physicalDescription: 'Tall, red hair',
    bloodType: 'O+',
    allergies: 'Peanuts',
    medications: 'Ibuprofen',
    medicalConditions: 'Asthma',
    emergencyInstructions: 'Call Bob first',
  ),
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

List<Override> _override(_FakeProfileController fake) => <Override>[
  profileControllerProvider.overrideWith(() => fake),
];

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  group('ProfileScreen — AppBar', () {
    testWidgets('renders "Profile" title in app bar', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(_FakeProfileController(_emptyState())),
      );
      expect(find.text(l10n.profileTitle), findsWidgets);
    });

    testWidgets('AppBar widget is present', (WidgetTester tester) async {
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(_FakeProfileController(_emptyState())),
      );
      expect(find.byType(AppBar), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  group('ProfileScreen — async states', () {
    testWidgets('shows CircularProgressIndicator while loading', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(_FakeProfileController(_emptyState())),
        settle: false,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('hides spinner once AsyncValue resolves', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(_FakeProfileController(_emptyState())),
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows error message on AsyncError', (
      WidgetTester tester,
    ) async {
      final controller = _FakeProfileController(_emptyState());
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(controller),
        settle: false,
      );
      // Force an error state after initial build completes.
      controller.state = const AsyncError<ProfileState>(
        'boom',
        StackTrace.empty,
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Error'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  group('ProfileScreen — name field', () {
    testWidgets('renders name text field with correct label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(_FakeProfileController(_emptyState())),
      );
      expect(find.text(l10n.profileFieldName), findsOneWidget);
    });

    testWidgets('populates name field from profile', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(_FakeProfileController(_populatedState())),
      );
      expect(find.widgetWithText(TextField, 'Alice'), findsOneWidget);
    });

    testWidgets('submitting name field calls patch with name', (
      WidgetTester tester,
    ) async {
      final fake = _FakeProfileController(_emptyState());
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(fake),
      );
      await tester.enterText(
        find.widgetWithText(TextField, l10n.profileFieldName),
        'Beatrice',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      check(fake.patchCalls).isGreaterOrEqual(1);
      check(fake.lastPatchedName).equals('Beatrice');
    });
  });

  // -------------------------------------------------------------------------
  group('ProfileScreen — phone field', () {
    testWidgets('renders phone field with correct label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(_FakeProfileController(_emptyState())),
      );
      expect(find.text(l10n.profileFieldPhone), findsOneWidget);
    });

    testWidgets('populates phone field from profile', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(_FakeProfileController(_populatedState())),
      );
      expect(find.widgetWithText(TextField, '+15550100'), findsOneWidget);
    });

    testWidgets('submitting phone field calls patch with phoneNumber', (
      WidgetTester tester,
    ) async {
      final fake = _FakeProfileController(_emptyState());
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(fake),
      );
      await tester.enterText(
        find.widgetWithText(TextField, l10n.profileFieldPhone),
        '+447911123456',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      check(fake.lastPatchedPhone).equals('+447911123456');
    });

    testWidgets('phone field uses phone keyboard type', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(_FakeProfileController(_emptyState())),
      );
      final tf = tester.widget<TextField>(
        find.widgetWithText(TextField, l10n.profileFieldPhone),
      );
      check(tf.keyboardType).equals(TextInputType.phone);
    });
  });

  // -------------------------------------------------------------------------
  group('ProfileScreen — age field', () {
    testWidgets('renders age field with correct label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(_FakeProfileController(_emptyState())),
      );
      expect(find.text(l10n.profileFieldAge), findsOneWidget);
    });

    testWidgets('populates age field from profile', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(_FakeProfileController(_populatedState())),
      );
      expect(find.widgetWithText(TextField, '30'), findsOneWidget);
    });

    testWidgets('age field uses number keyboard type', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(_FakeProfileController(_emptyState())),
      );
      final tf = tester.widget<TextField>(
        find.widgetWithText(TextField, l10n.profileFieldAge),
      );
      check(tf.keyboardType).equals(TextInputType.number);
    });

    testWidgets('submitting age field calls patch with parsed int', (
      WidgetTester tester,
    ) async {
      final fake = _FakeProfileController(_emptyState());
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(fake),
      );
      await tester.enterText(
        find.widgetWithText(TextField, l10n.profileFieldAge),
        '25',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      check(fake.lastPatchedAge).equals(25);
    });
  });

  // -------------------------------------------------------------------------
  group('ProfileScreen — physical description field', () {
    testWidgets('renders description field with correct label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(_FakeProfileController(_emptyState())),
      );
      expect(find.text(l10n.profileFieldDescription), findsOneWidget);
    });

    testWidgets('populates description field from profile', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(_FakeProfileController(_populatedState())),
      );
      expect(find.widgetWithText(TextField, 'Tall, red hair'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  group('ProfileScreen — blood type field', () {
    testWidgets('renders blood type field with correct label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(_FakeProfileController(_emptyState())),
      );
      expect(find.text(l10n.profileFieldBloodType), findsOneWidget);
    });

    testWidgets('populates blood type field from profile', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(_FakeProfileController(_populatedState())),
      );
      expect(find.widgetWithText(TextField, 'O+'), findsOneWidget);
    });

    testWidgets('submitting blood type calls patch with bloodType', (
      WidgetTester tester,
    ) async {
      final fake = _FakeProfileController(_emptyState());
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(fake),
      );
      await tester.enterText(
        find.widgetWithText(TextField, l10n.profileFieldBloodType),
        'AB-',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      check(fake.lastPatchedBloodType).equals('AB-');
    });
  });

  // -------------------------------------------------------------------------
  group('ProfileScreen — allergies field', () {
    testWidgets('renders allergies field with correct label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(_FakeProfileController(_emptyState())),
      );
      expect(find.text(l10n.profileFieldAllergies), findsOneWidget);
    });

    testWidgets('populates allergies field from profile', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(_FakeProfileController(_populatedState())),
      );
      expect(find.widgetWithText(TextField, 'Peanuts'), findsOneWidget);
    });

    testWidgets('submitting allergies calls patch with allergies', (
      WidgetTester tester,
    ) async {
      final fake = _FakeProfileController(_emptyState());
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(fake),
      );
      await tester.enterText(
        find.widgetWithText(TextField, l10n.profileFieldAllergies),
        'Latex, Penicillin',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      check(fake.lastPatchedAllergies).equals('Latex, Penicillin');
    });
  });

  // -------------------------------------------------------------------------
  group('ProfileScreen — medications field', () {
    testWidgets('renders medications field with correct label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(_FakeProfileController(_emptyState())),
      );
      expect(find.text(l10n.profileFieldMedications), findsOneWidget);
    });

    testWidgets('populates medications field from profile', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(_FakeProfileController(_populatedState())),
      );
      expect(find.widgetWithText(TextField, 'Ibuprofen'), findsOneWidget);
    });

    testWidgets('submitting medications calls patch with medications', (
      WidgetTester tester,
    ) async {
      final fake = _FakeProfileController(_emptyState());
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(fake),
      );
      await tester.enterText(
        find.widgetWithText(TextField, l10n.profileFieldMedications),
        'Metformin 500mg',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      check(fake.lastPatchedMedications).equals('Metformin 500mg');
    });
  });

  // -------------------------------------------------------------------------
  group('ProfileScreen — medical conditions field', () {
    testWidgets('renders conditions field with correct label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(_FakeProfileController(_emptyState())),
      );
      // Scroll to bring off-screen ListView items into view.
      await tester.scrollUntilVisible(
        find.text(l10n.profileFieldMedicalConditions),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(l10n.profileFieldMedicalConditions), findsOneWidget);
    });

    testWidgets('populates conditions field from profile', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(_FakeProfileController(_populatedState())),
      );
      await tester.scrollUntilVisible(
        find.widgetWithText(TextField, 'Asthma'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.widgetWithText(TextField, 'Asthma'), findsOneWidget);
    });

    testWidgets('submitting conditions calls patch with medicalConditions', (
      WidgetTester tester,
    ) async {
      final fake = _FakeProfileController(_emptyState());
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(fake),
      );
      await tester.scrollUntilVisible(
        find.widgetWithText(TextField, l10n.profileFieldMedicalConditions),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(
        find.widgetWithText(TextField, l10n.profileFieldMedicalConditions),
        'Diabetes Type 2',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      check(fake.lastPatchedConditions).equals('Diabetes Type 2');
    });
  });

  // -------------------------------------------------------------------------
  group('ProfileScreen — emergency instructions field', () {
    testWidgets('renders instructions field with correct label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(_FakeProfileController(_emptyState())),
      );
      await tester.scrollUntilVisible(
        find.text(l10n.profileFieldEmergencyInstructions),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(l10n.profileFieldEmergencyInstructions), findsOneWidget);
    });

    testWidgets('populates instructions field from profile', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(_FakeProfileController(_populatedState())),
      );
      await tester.scrollUntilVisible(
        find.widgetWithText(TextField, 'Call Bob first'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.widgetWithText(TextField, 'Call Bob first'), findsOneWidget);
    });

    testWidgets(
      'submitting instructions calls patch with emergencyInstructions',
      (WidgetTester tester) async {
        final fake = _FakeProfileController(_emptyState());
        final l10n = await loadL10n(const Locale('en'));
        await pumpScreen(
          tester,
          const ProfileScreen(),
          overrides: _override(fake),
        );
        await tester.scrollUntilVisible(
          find.widgetWithText(
            TextField,
            l10n.profileFieldEmergencyInstructions,
          ),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.enterText(
          find.widgetWithText(
            TextField,
            l10n.profileFieldEmergencyInstructions,
          ),
          'Use EpiPen in left pocket',
        );
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        check(fake.lastPatchedInstructions).equals('Use EpiPen in left pocket');
      },
    );
  });

  // -------------------------------------------------------------------------
  group('ProfileScreen — field count', () {
    testWidgets('renders all 9 TextField widgets including off-screen', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(_FakeProfileController(_emptyState())),
      );
      // name, phone, age, description, blood type, allergies,
      // medications, conditions, instructions.
      // skipOffstage: false counts items inside the ListView that have
      // been laid out but are currently scrolled off the viewport.
      expect(find.byType(TextField, skipOffstage: false), findsNWidgets(9));
    });
  });

  // -------------------------------------------------------------------------
  group('ProfileScreen — initialisation guard', () {
    testWidgets('fields are not re-initialised on rebuild', (
      WidgetTester tester,
    ) async {
      final fake = _FakeProfileController(_populatedState());
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(fake),
      );
      // Verify initial value shown.
      expect(find.widgetWithText(TextField, 'Alice'), findsOneWidget);
      // Trigger a state update — the field value must remain what the
      // user typed, not be reset from the new state.
      fake.state = const AsyncData(
        ProfileState(profile: UserProfile(name: 'Overwritten')),
      );
      await tester.pump();
      // _initialised guard prevents overwriting user-typed text.
      expect(find.widgetWithText(TextField, 'Alice'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  group('ProfileScreen — RTL', () {
    testWidgets('renders in Arabic (RTL) without overflow', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(_FakeProfileController(_emptyState())),
        locale: const Locale('ar'),
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // -------------------------------------------------------------------------
  group('ProfileScreen — dark mode', () {
    testWidgets('renders without exception in dark mode', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(_FakeProfileController(_populatedState())),
        themeMode: ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
    });
  });

  // -------------------------------------------------------------------------
  group('ProfileScreen — accessibility', () {
    testWidgets('all text fields have InputDecoration labels (semantics)', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(_FakeProfileController(_emptyState())),
      );
      // Each label is present — they form the accessible names for the
      // input fields used by assistive technology.
      // skipOffstage: false is required for ListView items below the fold.
      expect(
        find.text(l10n.profileFieldName, skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.text(l10n.profileFieldPhone, skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.text(l10n.profileFieldAge, skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.text(l10n.profileFieldDescription, skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.text(l10n.profileFieldBloodType, skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.text(l10n.profileFieldAllergies, skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.text(l10n.profileFieldMedications, skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.text(l10n.profileFieldMedicalConditions, skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.text(l10n.profileFieldEmergencyInstructions, skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('no exceptions under large font scale', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(
        () => tester.platformDispatcher.clearTextScaleFactorTestValue(),
      );
      await pumpScreen(
        tester,
        const ProfileScreen(),
        overrides: _override(_FakeProfileController(_populatedState())),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
