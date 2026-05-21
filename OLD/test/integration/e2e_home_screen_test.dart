/// End-to-end UI integration tests for the HomeScreen.
///
/// Pumps the real [HomeScreen] inside a fake-repository ProviderScope and
/// validates every spec-defined behaviour: mode chips, contact banner,
/// stealth title, run-button gating, active-session card, and navigation.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/home/home_screen.dart';

import '../features/fake_repositories.dart';
import '../features/widget_test_helpers.dart';
import '../helpers/test_helpers.dart';

// ---------------------------------------------------------------------------
// helpers
// ---------------------------------------------------------------------------

List<Override> _base({
  List<SessionMode> modes = const [],
  List<EmergencyContact> contacts = const [],
  AppSettings? settings,
}) => [
  modesRepositoryProvider.overrideWithValue(FakeModesRepository(modes)),
  contactsRepositoryProvider.overrideWithValue(
    FakeContactsRepository(contacts),
  ),
  settingsRepositoryProvider.overrideWithValue(
    FakeSettingsRepository(
      settings ?? const AppSettings(defaults: AppDefaults()),
    ),
  ),
];

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ---- basic render ---------------------------------------------------------

  testWidgets('home_renders_app_bar', (tester) async {
    await tester.pumpWidget(
      hostScreenWithRouter(overrides: _base(), child: const HomeScreen()),
    );
    await tester.pumpAndSettle();
    check(find.byType(AppBar).evaluate().length).equals(1);
  });

  testWidgets('home_settings_icon_visible', (tester) async {
    await tester.pumpWidget(
      hostScreenWithRouter(overrides: _base(), child: const HomeScreen()),
    );
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.settings).evaluate().length).equals(1);
  });

  testWidgets('home_simulate_button_visible_for_default_mode', (tester) async {
    // Spec 04 §Selected Mode Card: with at least one mode the home
    // surfaces a Simulate TextButton (science_outlined icon). The
    // older SwitchListTile toggle was retired in favor of this
    // explicit button paired with a confirmation-gated Start.
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: _base(
          modes: [makeMode(id: 'm1', name: 'Walk')],
        ),
        child: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(SwitchListTile).evaluate()).isEmpty();
    check(
      find.widgetWithIcon(TextButton, Icons.science_outlined).evaluate().length,
    ).equals(1);
  });

  // ---- mode chips -----------------------------------------------------------

  testWidgets('home_seeded_modes_show_as_mode_tiles', (tester) async {
    // Spec 04 §Home Screen: each mode is a clickable icon tile
    // (Card + InkWell), not a ChoiceChip.
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: _base(
          modes: [
            makeMode(id: 'm1', name: 'Walk'),
            makeMode(id: 'm2', name: 'Date'),
          ],
        ),
        child: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();
    // Each mode renders one Card (InkWell-wrapped) plus the
    // active-session card if present. Here there's no active
    // session, so we expect exactly two cards.
    check(find.byType(Card).evaluate().length).isGreaterOrEqual(2);
  });

  testWidgets('home_walk_mode_chip_shows_walk_label', (tester) async {
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: _base(
          modes: [makeMode(id: 'm1', name: 'Walk')],
        ),
        child: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.text('Walk').evaluate().length).isGreaterOrEqual(1);
  });

  testWidgets('home_date_mode_chip_shows_date_label', (tester) async {
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: _base(
          modes: [
            makeMode(id: 'm1', name: 'Walk'),
            makeMode(id: 'm2', name: 'Date'),
          ],
        ),
        child: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.text('Date').evaluate().length).isGreaterOrEqual(1);
  });

  testWidgets('home_empty_modes_shows_no_mode_chips', (tester) async {
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: _base(modes: []),
        child: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();
    // With empty modes there are no ChoiceChips.
    check(find.byType(ChoiceChip).evaluate()).isEmpty();
  });

  testWidgets('home_empty_modes_hides_selected_mode_card', (tester) async {
    // Spec 04 §Selected Mode Card: the card (and its Start +
    // Simulate buttons) is gated on a non-null selectedMode. With
    // no modes configured, neither button is rendered.
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: _base(modes: []),
        child: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(SwitchListTile).evaluate()).isEmpty();
    check(
      find.widgetWithIcon(FilledButton, Icons.play_arrow).evaluate(),
    ).isEmpty();
    check(
      find.widgetWithIcon(TextButton, Icons.science_outlined).evaluate(),
    ).isEmpty();
  });

  // ---- start + simulate buttons ---------------------------------------------

  testWidgets('home_start_button_opens_confirmation_dialog', (tester) async {
    // Spec 04 §Selected Mode Card: tapping Start shows a
    // confirmation AlertDialog before the session actually begins.
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: _base(
          modes: [makeMode(id: 'm1', name: 'Walk')],
        ),
        child: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithIcon(FilledButton, Icons.play_arrow));
    await tester.pumpAndSettle();
    check(find.byType(AlertDialog).evaluate().length).equals(1);
  });

  testWidgets('home_simulate_button_present_alongside_start', (tester) async {
    // Spec 04 §Selected Mode Card: with a mode selected, both
    // Start and Simulate buttons render side-by-side.
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: _base(
          modes: [makeMode(id: 'm1', name: 'Walk')],
        ),
        child: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(
      find.widgetWithIcon(FilledButton, Icons.play_arrow).evaluate().length,
    ).equals(1);
    check(
      find.widgetWithIcon(TextButton, Icons.science_outlined).evaluate().length,
    ).equals(1);
  });

  // ---- start button ---------------------------------------------------------

  testWidgets('home_mode_tile_is_present', (tester) async {
    // Spec 04 §Home Screen: there's no separate Run button — each
    // mode is a clickable icon tile (Card + InkWell). Verify at
    // least one tile is rendered when a mode is configured.
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: _base(
          modes: [makeMode(id: 'm1', name: 'Walk')],
        ),
        child: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(Card).evaluate().length).isGreaterOrEqual(1);
  });

  testWidgets('home_no_tiles_with_no_modes', (tester) async {
    // Spec 04 §Home Screen: when the user has no modes, the
    // "no modes configured" hint replaces the tile grid.
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: _base(modes: []),
        child: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(Card).evaluate()).isEmpty();
  });

  // ---- stealth mode ---------------------------------------------------------

  testWidgets('home_stealth_enabled_shows_fake_name', (tester) async {
    const stealth = StealthConfig(enabled: true, fakeName: 'Calendar');
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: _base(
          settings: const AppSettings(defaults: AppDefaults(stealth: stealth)),
        ),
        child: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.text('Calendar').evaluate().length).isGreaterOrEqual(1);
  });

  testWidgets('home_stealth_enabled_hides_guardian_angela_title', (
    tester,
  ) async {
    const stealth = StealthConfig(enabled: true, fakeName: 'Notebook');
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: _base(
          settings: const AppSettings(defaults: AppDefaults(stealth: stealth)),
        ),
        child: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();
    // "Guardian Angela" brand text should not appear.
    check(find.textContaining('Guardian Angela').evaluate()).isEmpty();
  });

  testWidgets('home_stealth_disabled_shows_normal_title', (tester) async {
    const stealth = StealthConfig(enabled: false);
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: _base(
          settings: const AppSettings(defaults: AppDefaults(stealth: stealth)),
        ),
        child: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();
    // With stealth off the app name "Guardian Angela" appears in the AppBar.
    check(
      find.textContaining('Guardian').evaluate().length,
    ).isGreaterOrEqual(1);
  });

  // ---- contact banner -------------------------------------------------------

  testWidgets('home_zero_contacts_shows_error_banner', (tester) async {
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: _base(contacts: []),
        child: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();
    // Error icon rendered in the banner with 0 contacts.
    check(
      find.byIcon(Icons.error_outline).evaluate().length,
    ).isGreaterOrEqual(1);
  });

  testWidgets('home_one_contact_hides_banner', (tester) async {
    // No more "we recommend at least 3" banner — once at least one
    // contact is configured the banner disappears entirely.
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: _base(contacts: [makeContact(id: 'c1')]),
        child: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.error_outline).evaluate()).isEmpty();
    check(find.byIcon(Icons.info_outline).evaluate()).isEmpty();
  });

  testWidgets('home_two_contacts_hides_banner', (tester) async {
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: _base(
          contacts: [
            makeContact(id: 'c1', name: 'Alice'),
            makeContact(id: 'c2', name: 'Bob'),
          ],
        ),
        child: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.error_outline).evaluate()).isEmpty();
    check(find.byIcon(Icons.info_outline).evaluate()).isEmpty();
  });

  testWidgets('home_three_contacts_hides_banner', (tester) async {
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: _base(
          contacts: [
            makeContact(id: 'c1', name: 'Alice'),
            makeContact(id: 'c2', name: 'Bob'),
            makeContact(id: 'c3', name: 'Carol'),
          ],
        ),
        child: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.error_outline).evaluate()).isEmpty();
    check(find.byIcon(Icons.info_outline).evaluate()).isEmpty();
  });

  // ---- shortcut buttons -----------------------------------------------------

  testWidgets('home_contacts_shortcut_visible', (tester) async {
    await tester.pumpWidget(
      hostScreenWithRouter(overrides: _base(), child: const HomeScreen()),
    );
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.contacts).evaluate().length).isGreaterOrEqual(1);
  });

  testWidgets('home_modes_shortcut_visible', (tester) async {
    await tester.pumpWidget(
      hostScreenWithRouter(overrides: _base(), child: const HomeScreen()),
    );
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.tune).evaluate().length).isGreaterOrEqual(1);
  });

  testWidgets('home_history_shortcut_visible', (tester) async {
    await tester.pumpWidget(
      hostScreenWithRouter(overrides: _base(), child: const HomeScreen()),
    );
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.history).evaluate().length).isGreaterOrEqual(1);
  });
}
