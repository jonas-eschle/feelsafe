/// Widget tests for [SmsContactGrid] (spec 04 §SMS Contact Selection).
///
/// A [_GridHost] holds the [SmsContactConfig] and rebuilds on `onChanged`, so
/// tests can drive real toggles and assert both the emitted config and the
/// re-rendered UI.
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/enums/sms_contact_selection.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/features/modes/widgets/sms_contact_grid.dart';
import '../../../helpers/widget_test_helpers.dart';

EmergencyContact _contact(
  String id,
  String name, {
  List<MessageChannel> channels = const <MessageChannel>[MessageChannel.sms],
  int sortOrder = 0,
}) => EmergencyContact(
  id: id,
  name: name,
  phoneNumber: '+1555000$sortOrder',
  sortOrder: sortOrder,
  channels: channels,
);

class _GridHost extends StatefulWidget {
  const _GridHost({
    required this.contacts,
    required this.initial,
    this.onManage,
  });

  final List<EmergencyContact> contacts;
  final SmsContactConfig initial;
  final VoidCallback? onManage;

  @override
  State<_GridHost> createState() => _GridHostState();
}

class _GridHostState extends State<_GridHost> {
  late SmsContactConfig config = widget.initial;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SingleChildScrollView(
      child: SmsContactGrid(
        contacts: widget.contacts,
        config: config,
        onChanged: (SmsContactConfig c) => setState(() => config = c),
        onManageContacts: widget.onManage ?? () {},
      ),
    ),
  );
}

SmsContactConfig _config(SmsContactSelection sel, {List<String>? ids}) =>
    SmsContactConfig(contactSelection: sel, contactIds: ids);

SmsContactConfig _hostConfig(WidgetTester tester) =>
    tester.state<_GridHostState>(find.byType(_GridHost)).config;

void main() {
  group('SmsContactGrid — empty state', () {
    testWidgets('shows add-contact prompt and deep-links on tap', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      bool tapped = false;
      await pumpScreen(
        tester,
        _GridHost(
          contacts: const <EmergencyContact>[],
          initial: _config(SmsContactSelection.allContacts),
          onManage: () => tapped = true,
        ),
      );
      expect(find.text(l10n.smsContactEmptyAddPrompt), findsOneWidget);
      await tester.tap(find.text(l10n.smsContactEmptyAddPrompt));
      await tester.pump();
      check(tapped).isTrue();
    });
  });

  group('SmsContactGrid — rendering', () {
    testWidgets('renders one chip per contact, capable and incapable', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        _GridHost(
          contacts: <EmergencyContact>[
            _contact('a', 'Alice'),
            _contact('b', 'Bob', sortOrder: 1),
            _contact(
              'c',
              'Carol',
              channels: const <MessageChannel>[MessageChannel.whatsapp],
              sortOrder: 2,
            ),
          ],
          initial: _config(SmsContactSelection.allContacts),
        ),
      );
      expect(find.widgetWithText(FilterChip, 'Alice'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Bob'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Carol'), findsOneWidget);
    });

    testWidgets('an SMS-incapable contact chip is disabled', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        _GridHost(
          contacts: <EmergencyContact>[
            _contact('a', 'Alice'),
            _contact(
              'c',
              'Carol',
              channels: const <MessageChannel>[MessageChannel.whatsapp],
              sortOrder: 1,
            ),
          ],
          initial: _config(SmsContactSelection.allContacts),
        ),
      );
      final FilterChip carol = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Carol'),
      );
      check(carol.onSelected).isNull();
      final FilterChip alice = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Alice'),
      );
      check(alice.onSelected).isNotNull();
    });

    testWidgets('allContacts selects every capable chip', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        _GridHost(
          contacts: <EmergencyContact>[
            _contact('a', 'Alice'),
            _contact('b', 'Bob', sortOrder: 1),
          ],
          initial: _config(SmsContactSelection.allContacts),
        ),
      );
      check(
        tester
            .widget<FilterChip>(find.widgetWithText(FilterChip, 'Alice'))
            .selected,
      ).isTrue();
      check(
        tester
            .widget<FilterChip>(find.widgetWithText(FilterChip, 'Bob'))
            .selected,
      ).isTrue();
      expect(find.text(l10n.smsContactSummaryAll), findsOneWidget);
    });
  });

  group('SmsContactGrid — selection inference', () {
    testWidgets('deselecting one (from all) yields specificIds with the rest', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        _GridHost(
          contacts: <EmergencyContact>[
            _contact('a', 'Alice'),
            _contact('b', 'Bob', sortOrder: 1),
          ],
          initial: _config(SmsContactSelection.allContacts),
        ),
      );
      await tester.tap(find.widgetWithText(FilterChip, 'Bob'));
      await tester.pumpAndSettle();
      final SmsContactConfig c = _hostConfig(tester);
      check(c.contactSelection).equals(SmsContactSelection.specificIds);
      check(c.contactIds).isNotNull();
      check(c.contactIds!).deepEquals(<String>['a']);
    });

    testWidgets(
      'reselecting the last missing capable contact infers allContacts '
      'with contactIds == null',
      (WidgetTester tester) async {
        // Start from a strict subset (only Alice).
        await pumpScreen(
          tester,
          _GridHost(
            contacts: <EmergencyContact>[
              _contact('a', 'Alice'),
              _contact('b', 'Bob', sortOrder: 1),
            ],
            initial: _config(
              SmsContactSelection.specificIds,
              ids: <String>['a'],
            ),
          ),
        );
        // Selecting Bob makes the full set → must collapse to allContacts/null.
        await tester.tap(find.widgetWithText(FilterChip, 'Bob'));
        await tester.pumpAndSettle();
        final SmsContactConfig c = _hostConfig(tester);
        check(c.contactSelection).equals(SmsContactSelection.allContacts);
        // Critical: a non-null id list under allContacts is treated as
        // specific IDs by the runtime resolver, so it MUST be null here.
        check(c.contactIds).isNull();
      },
    );

    testWidgets('incapable contacts are never part of the saved selection', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        _GridHost(
          contacts: <EmergencyContact>[
            _contact('a', 'Alice'),
            _contact(
              'c',
              'Carol',
              channels: const <MessageChannel>[MessageChannel.whatsapp],
              sortOrder: 1,
            ),
          ],
          initial: _config(SmsContactSelection.allContacts),
        ),
      );
      // Deselect Alice → only the incapable Carol would remain; selection must
      // become specificIds with an empty list (Carol is never included).
      await tester.tap(find.widgetWithText(FilterChip, 'Alice'));
      await tester.pumpAndSettle();
      final SmsContactConfig c = _hostConfig(tester);
      check(c.contactSelection).equals(SmsContactSelection.specificIds);
      check(c.contactIds).isNotNull();
      check(c.contactIds!).isEmpty();
    });
  });

  group('SmsContactGrid — selection resolution edge cases', () {
    testWidgets(
      'legacy allContacts + explicit ids resolves as the specific ids',
      (WidgetTester tester) async {
        // Mirrors the runtime resolver: a legacy config that says allContacts
        // but still carries ids must select ONLY those ids (spec 02 §SMS
        // recipient resolution).
        await pumpScreen(
          tester,
          _GridHost(
            contacts: <EmergencyContact>[
              _contact('a', 'Alice'),
              _contact('b', 'Bob', sortOrder: 1),
            ],
            initial: _config(
              SmsContactSelection.allContacts,
              ids: <String>['a'],
            ),
          ),
        );
        check(
          tester
              .widget<FilterChip>(find.widgetWithText(FilterChip, 'Alice'))
              .selected,
        ).isTrue();
        check(
          tester
              .widget<FilterChip>(find.widgetWithText(FilterChip, 'Bob'))
              .selected,
        ).isFalse();
      },
    );

    testWidgets('firstContact selects only the lowest-sortOrder capable chip', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        _GridHost(
          contacts: <EmergencyContact>[
            // Out of insertion order on purpose — sortOrder must decide.
            _contact('b', 'Bob', sortOrder: 1),
            _contact('a', 'Alice'),
          ],
          initial: _config(SmsContactSelection.firstContact),
        ),
      );
      check(
        tester
            .widget<FilterChip>(find.widgetWithText(FilterChip, 'Alice'))
            .selected,
      ).isTrue();
      check(
        tester
            .widget<FilterChip>(find.widgetWithText(FilterChip, 'Bob'))
            .selected,
      ).isFalse();
    });

    testWidgets('firstContact with no capable contact selects nothing', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        _GridHost(
          contacts: <EmergencyContact>[
            _contact(
              'c',
              'Carol',
              channels: const <MessageChannel>[MessageChannel.whatsapp],
            ),
          ],
          initial: _config(SmsContactSelection.firstContact),
        ),
      );
      expect(find.text(l10n.smsContactSummaryNone), findsOneWidget);
    });
  });
}
