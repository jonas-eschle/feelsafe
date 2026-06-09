/// Widget tests for [ReminderConfirmation] and [ReminderDisguiseContent] —
/// the four disguisedReminder confirmation interactions (spec 02
/// §disguisedReminder Disarm) and the disguise card content.
library;

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/widgets/swipe_slider.dart';
import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/features/disguised_reminder/reminder_confirmation.dart';
import 'package:guardianangela/features/disguised_reminder/reminder_word_choices.dart';
import 'package:guardianangela/features/template_editor/reminder_template_form.dart';
import '../../helpers/widget_test_helpers.dart';

ReminderTemplate _template({
  required ConfirmationType confirmationType,
  String? keyword,
  String? buttonLabel,
  String? subtitle,
  String? iconAsset,
  String? imagePath,
  ReminderDisplayStyle displayStyle = ReminderDisplayStyle.subtle,
}) => ReminderTemplate(
  id: 'tmpl',
  name: 'Template',
  title: 'You have an appointment',
  body: 'Meeting with Alex at 3 PM',
  subtitle: subtitle,
  iconAsset: iconAsset,
  imagePath: imagePath,
  confirmationType: confirmationType,
  keyword: keyword,
  buttonLabel: buttonLabel,
  isCustom: false,
  displayStyle: displayStyle,
  isGlobal: true,
);

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
}) => pumpScreen(
  tester,
  Scaffold(body: Center(child: child)),
  locale: locale,
);

void main() {
  group('ReminderConfirmation — tapButton', () {
    testWidgets('renders the template buttonLabel and confirms on tap', (
      tester,
    ) async {
      var confirmed = 0;
      await _pump(
        tester,
        ReminderConfirmation(
          template: _template(
            confirmationType: ConfirmationType.tapButton,
            buttonLabel: 'Acknowledge',
          ),
          onConfirm: () => confirmed++,
        ),
      );
      expect(find.text('Acknowledge'), findsOneWidget);
      await tester.tap(find.text('Acknowledge'));
      expect(confirmed, 1);
    });

    testWidgets('falls back to the default label when none is set', (
      tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        ReminderConfirmation(
          template: _template(confirmationType: ConfirmationType.tapButton),
          onConfirm: () {},
        ),
      );
      expect(find.text(l10n.sessionReminderDefaultButton), findsOneWidget);
    });
  });

  group('ReminderConfirmation — tapWord', () {
    testWidgets('shows the keyword among the choices', (tester) async {
      await _pump(
        tester,
        ReminderConfirmation(
          template: _template(
            confirmationType: ConfirmationType.tapWord,
            keyword: 'STREAK',
          ),
          onConfirm: () {},
        ),
      );
      expect(find.text('STREAK'), findsOneWidget);
      // Three choices are rendered as buttons.
      expect(find.byType(OutlinedButton), findsNWidgets(3));
    });

    testWidgets('tapping the correct word confirms', (tester) async {
      var confirmed = 0;
      await _pump(
        tester,
        ReminderConfirmation(
          template: _template(
            confirmationType: ConfirmationType.tapWord,
            keyword: 'STREAK',
          ),
          onConfirm: () => confirmed++,
        ),
      );
      await tester.tap(find.text('STREAK'));
      expect(confirmed, 1);
    });

    testWidgets('tapping a decoy word does NOT confirm', (tester) async {
      var confirmed = 0;
      const keyword = 'STREAK';
      final decoy = buildReminderWordChoices(
        keyword,
      ).firstWhere((w) => w != keyword);
      await _pump(
        tester,
        ReminderConfirmation(
          template: _template(
            confirmationType: ConfirmationType.tapWord,
            keyword: keyword,
          ),
          onConfirm: () => confirmed++,
        ),
      );
      await tester.tap(find.text(decoy));
      expect(confirmed, 0);
    });
  });

  group('ReminderConfirmation — swipe', () {
    testWidgets('renders a SwipeSlider with the swipe label', (tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        ReminderConfirmation(
          template: _template(confirmationType: ConfirmationType.swipe),
          onConfirm: () {},
        ),
      );
      expect(find.byType(SwipeSlider), findsOneWidget);
      expect(find.text(l10n.sessionReminderSwipeLabel), findsOneWidget);
    });
  });

  group('ReminderConfirmation — dismiss', () {
    testWidgets('renders the dismiss button and confirms on tap', (
      tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      var confirmed = 0;
      await _pump(
        tester,
        ReminderConfirmation(
          template: _template(confirmationType: ConfirmationType.dismiss),
          onConfirm: () => confirmed++,
        ),
      );
      expect(find.text(l10n.sessionReminderDismissLabel), findsOneWidget);
      await tester.tap(find.text(l10n.sessionReminderDismissLabel));
      expect(confirmed, 1);
    });
  });

  group('ReminderDisguiseContent', () {
    testWidgets('renders title, body, and the confirmation', (tester) async {
      await _pump(
        tester,
        ReminderDisguiseContent(
          template: _template(
            confirmationType: ConfirmationType.tapButton,
            buttonLabel: 'View',
          ),
          onConfirm: () {},
        ),
      );
      expect(find.text('You have an appointment'), findsOneWidget);
      expect(find.text('Meeting with Alex at 3 PM'), findsOneWidget);
      expect(find.text('View'), findsOneWidget);
    });

    testWidgets('renders the optional subtitle when present', (tester) async {
      await _pump(
        tester,
        ReminderDisguiseContent(
          template: _template(
            confirmationType: ConfirmationType.dismiss,
            subtitle: 'Tomorrow, 9:00 AM',
          ),
          onConfirm: () {},
        ),
      );
      expect(find.text('Tomorrow, 9:00 AM'), findsOneWidget);
    });
  });

  group('ReminderDisguiseContent — template icon (#18)', () {
    testWidgets('falls back to the Material notification icon when unset', (
      tester,
    ) async {
      await _pump(
        tester,
        ReminderDisguiseContent(
          template: _template(confirmationType: ConfirmationType.dismiss),
          onConfirm: () {},
        ),
      );
      expect(find.byIcon(Icons.notifications_active_outlined), findsOneWidget);
      // No image is rendered in the fallback path.
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('renders the category Material icon from iconAsset', (
      tester,
    ) async {
      // The template editor persists a category KEY (e.g. 'fitness') into
      // iconAsset; it must map to that category's Material symbol, NOT the
      // notification fallback.
      await _pump(
        tester,
        ReminderDisguiseContent(
          template: _template(
            confirmationType: ConfirmationType.dismiss,
            iconAsset: 'fitness',
          ),
          onConfirm: () {},
        ),
      );
      expect(find.byIcon(reminderIconDataFor('fitness')), findsOneWidget);
      expect(find.byIcon(Icons.notifications_active_outlined), findsNothing);
    });

    testWidgets('renders an Image when iconAsset is an asset path', (
      tester,
    ) async {
      await _pump(
        tester,
        ReminderDisguiseContent(
          template: _template(
            confirmationType: ConfirmationType.dismiss,
            iconAsset: 'assets/icons/calendar.png',
          ),
          onConfirm: () {},
        ),
      );
      // The render path is the image branch (asset is absent in the test
      // bundle, so it degrades to the Material fallback via errorBuilder —
      // but an Image widget is still constructed for the path).
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets(
      'renders an Image when imagePath is set (wins over iconAsset)',
      (tester) async {
        await _pump(
          tester,
          ReminderDisguiseContent(
            template: _template(
              confirmationType: ConfirmationType.dismiss,
              iconAsset: 'fitness',
              imagePath: 'assets/disguise/calendar_full.png',
            ),
            onConfirm: () {},
          ),
        );
        // imagePath takes precedence: an Image is rendered and the iconAsset
        // category Material icon is NOT.
        expect(find.byType(Image), findsOneWidget);
        expect(find.byIcon(reminderIconDataFor('fitness')), findsNothing);
      },
    );

    testWidgets('an absolute path renders from the device file system', (
      tester,
    ) async {
      await _pump(
        tester,
        ReminderDisguiseContent(
          template: _template(
            confirmationType: ConfirmationType.dismiss,
            imagePath: '/nonexistent_c7c/disguise.png',
          ),
          onConfirm: () {},
        ),
      );
      final Image img = tester.widget<Image>(find.byType(Image));
      expect(img.image, isA<FileImage>());
      expect(
        (img.image as FileImage).file.path,
        '/nonexistent_c7c/disguise.png',
      );
    });

    testWidgets('a bare filename with an image extension is asset-loaded', (
      tester,
    ) async {
      // No slash, but '.png' marks it as a path, not a category key.
      await _pump(
        tester,
        ReminderDisguiseContent(
          template: _template(
            confirmationType: ConfirmationType.dismiss,
            iconAsset: 'photo.png',
          ),
          onConfirm: () {},
        ),
      );
      final Image img = tester.widget<Image>(find.byType(Image));
      expect(img.image, isA<AssetImage>());
    });

    testWidgets('an unknown non-path iconAsset keeps the neutral fallback', (
      tester,
    ) async {
      // Neither a category key nor path-like: the disguise must degrade to
      // the Material fallback, never an error glyph or a broken image.
      await _pump(
        tester,
        ReminderDisguiseContent(
          template: _template(
            confirmationType: ConfirmationType.dismiss,
            iconAsset: 'mystery',
          ),
          onConfirm: () {},
        ),
      );
      expect(find.byType(Image), findsNothing);
      expect(find.byIcon(Icons.notifications_active_outlined), findsOneWidget);
    });
  });

  group('ReminderConfirmation — tapWord localized decoys (#18)', () {
    testWidgets('decoys render in the active locale, not English', (
      tester,
    ) async {
      // Drive the Spanish locale: decoys must come from the es pool
      // (e.g. CERRAR) and none of the English fallback words may appear.
      await _pump(
        tester,
        ReminderConfirmation(
          template: _template(
            confirmationType: ConfirmationType.tapWord,
            keyword: 'STREAK',
          ),
          onConfirm: () {},
        ),
        locale: const Locale('es'),
      );
      final l10n = await loadL10n(const Locale('es'));
      final esPool = <String>[
        for (final w in l10n.sessionReminderDecoyWords.split(','))
          if (w.trim().isNotEmpty) w.trim().toUpperCase(),
      ];
      // The keyword is present.
      expect(find.text('STREAK'), findsOneWidget);
      // Every rendered choice other than the keyword is a Spanish decoy.
      final buttons = tester
          .widgetList<OutlinedButton>(find.byType(OutlinedButton))
          .toList();
      expect(buttons.length, 3);
      var localizedDecoys = 0;
      for (final btn in buttons) {
        final label = (btn.child as Text?)?.data ?? '';
        if (label == 'STREAK') {
          continue;
        }
        expect(esPool, contains(label));
        expect(kReminderDecoyPoolFallback, isNot(contains(label)));
        localizedDecoys++;
      }
      expect(localizedDecoys, 2);
    });

    testWidgets('the keyword still confirms with a localized pool', (
      tester,
    ) async {
      var confirmed = 0;
      await _pump(
        tester,
        ReminderConfirmation(
          template: _template(
            confirmationType: ConfirmationType.tapWord,
            keyword: 'STREAK',
          ),
          onConfirm: () => confirmed++,
        ),
        locale: const Locale('es'),
      );
      await tester.tap(find.text('STREAK'));
      expect(confirmed, 1);
    });
  });
}
