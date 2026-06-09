import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/core/utils/permission_utils.dart';
import 'package:guardianangela/data/seed_data.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/features/home/home_checklist_repository.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Post-onboarding safety setup banner card at the top of the home
/// screen (spec 04 §Safety Setup Checklist, lines 480-518).
///
/// Renders a collapsible card with a progress bar and 6 tappable rows.
/// Each row encodes a setup task — add a contact, set a PIN, enable
/// stealth, test a simulation, customize a mode, grant notification
/// permission — and resolves its completion state from a mix of
/// [HomeChecklistDeps]:
///
/// 1. Contacts come from the [HomeController] state.
/// 2. PIN, stealth: from [AppSettings].
/// 3. Simulation flag, dismiss flag, first-visit flag: from
///    [HomeChecklistRepository].
/// 4. Notification permission: from `permission_handler`.
/// 5. Custom mode: any [SessionMode] whose id is not a seed id.
///
/// When all six items are complete the card is replaced by a brief
/// "all set" confirmation banner for the rest of the visit; the banner
/// auto-dismisses on the next visit (spec 04:513). The card also
/// vanishes immediately after the user taps [×]. On the first render the
/// card is expanded; subsequent renders collapse it (still toggleable).
class SafetySetupChecklist extends ConsumerStatefulWidget {
  /// Creates a [SafetySetupChecklist].
  const SafetySetupChecklist({
    super.key,
    required this.contacts,
    required this.modes,
    this.permissionLookup,
    this.permissionRequester,
  });

  /// Reactive contacts list driving the "Add an emergency contact" row.
  final List<EmergencyContact> contacts;

  /// Reactive modes list driving the "Customize a safety mode" row.
  final List<SessionMode> modes;

  /// Permission-status lookup. Defaults to
  /// `Permission.notification.status.isGranted`. Tests inject a fake.
  final Future<bool> Function()? permissionLookup;

  /// Permission requester. Defaults to the shared
  /// [ensureNotificationPermission] helper (rationale dialog + OS prompt, or
  /// a deep-link into system settings on permanent denial). Tests inject a
  /// fake.
  final Future<bool> Function()? permissionRequester;

  @override
  ConsumerState<SafetySetupChecklist> createState() =>
      _SafetySetupChecklistState();
}

class _SafetySetupChecklistState extends ConsumerState<SafetySetupChecklist>
    with WidgetsBindingObserver {
  bool _loading = true;
  bool _dismissed = false;
  bool _expanded = true;
  bool _pinDone = false;
  bool _stealthDone = false;
  bool _simulationDone = false;
  bool _permissionDone = false;

  /// Whether the "all set" banner was already shown on a prior visit
  /// (snapshot taken at visit start in [_refresh]). Gates [build] so the
  /// banner is a one-time celebration.
  bool _allDoneCelebrated = false;

  /// Transient guard so the celebration flag is persisted at most once
  /// per visit, the first time every item is complete.
  bool _allDonePersisted = false;

  HomeChecklistRepository get _repo =>
      ref.read(homeChecklistRepositoryProvider);

  Future<bool> _checkPermission() async {
    final lookup = widget.permissionLookup;
    if (lookup != null) return lookup();
    return Permission.notification.status.then((PermissionStatus s) {
      return s.isGranted;
    });
  }

  Future<bool> _requestPermission() async {
    final requester = widget.permissionRequester;
    if (requester != null) return requester();
    // Delegate to the shared helper (spec 04:504 item 6) so the re-ask
    // rationale + deep-link logic lives in one place.
    return ensureNotificationPermission(context);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  Future<void> _refresh() async {
    final dismissed = await _repo.dismissed();
    final firstVisitDone = await _repo.firstVisitDone();
    final simulationDone = await _repo.simulationDone();
    final allDoneCelebrated = await _repo.allDoneCelebrated();
    final settings = await ref.read(appSettingsRepositoryProvider).load();
    final permissionGranted = await _checkPermission();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _dismissed = dismissed;
      _expanded = !firstVisitDone;
      _pinDone = settings.sessionEndPinHash != null;
      _stealthDone = settings.defaults.stealth.enabled;
      _simulationDone = simulationDone;
      _permissionDone = permissionGranted;
      _allDoneCelebrated = allDoneCelebrated;
    });
    if (!firstVisitDone) {
      await _repo.markFirstVisitDone();
    }
    _persistAllDoneIfNeeded();
  }

  /// Persists the celebration flag the first time every item is complete.
  /// The snapshot [_allDoneCelebrated] — read at visit start and re-read
  /// by [_refresh] (including on app-resume) — still gates [build], so
  /// writing here keeps the banner visible until the next [_refresh]
  /// (navigating away or resuming the app), at which point it
  /// auto-dismisses.
  void _persistAllDoneIfNeeded() {
    if (_doneCount == 6 && !_allDoneCelebrated && !_allDonePersisted) {
      _allDonePersisted = true;
      unawaited(_repo.markAllDoneCelebrated());
    }
  }

  bool get _item1Done => widget.contacts.isNotEmpty;
  bool get _item5Done =>
      widget.modes.any((SessionMode m) => !_isSeedModeId(m.id));
  int get _doneCount => <bool>[
    _item1Done,
    _pinDone,
    _stealthDone,
    _simulationDone,
    _item5Done,
    _permissionDone,
  ].where((bool b) => b).length;

  @override
  Widget build(BuildContext context) {
    if (_loading || _dismissed) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    if (_doneCount == 6) {
      // Every item complete: celebrate once. Show the banner this visit,
      // then stay hidden on subsequent visits (spec 04:513).
      if (_allDoneCelebrated) return const SizedBox.shrink();
      return _AllDoneBanner(message: l10n.homeChecklistAllDoneBanner);
    }
    return Card(
      key: const Key('safety-setup-checklist-card'),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _Header(
            doneCount: _doneCount,
            expanded: _expanded,
            onToggle: () => setState(() => _expanded = !_expanded),
            onDismiss: _onDismiss,
          ),
          LinearProgressIndicator(value: _doneCount / 6),
          if (_expanded) ...<Widget>[
            for (final spec in _itemSpecs(l10n)) _Row(spec: spec),
          ],
        ],
      ),
    );
  }

  Future<void> _onDismiss() async {
    setState(() => _dismissed = true);
    await _repo.setDismissed();
  }

  List<_ItemSpec> _itemSpecs(AppLocalizations l10n) => <_ItemSpec>[
    _ItemSpec(
      done: _item1Done,
      title: l10n.homeChecklistItem1Title,
      infoBody: l10n.checklistInfo1Body,
      onTap: _item1Done ? null : () => _navTo(RouteNames.contactForm),
    ),
    _ItemSpec(
      done: _pinDone,
      title: l10n.homeChecklistItem2Title,
      infoBody: l10n.checklistInfo2Body,
      onTap: _pinDone
          ? null
          : () => _navTo(
              RouteNames.pinSetup,
              queryParameters: const <String, String>{'type': 'sessionEnd'},
            ),
    ),
    _ItemSpec(
      done: _stealthDone,
      title: l10n.homeChecklistItem3Title,
      infoBody: l10n.checklistInfo3Body,
      onTap: _stealthDone
          ? null
          : () => _showTutorial(
              title: l10n.homeChecklistItem3Title,
              body: l10n.checklistTutorial3Body,
              goThereTarget: RouteNames.settingsStealth,
            ),
    ),
    _ItemSpec(
      done: _simulationDone,
      title: l10n.homeChecklistItem4Title,
      infoBody: l10n.checklistInfo4Body,
      onTap: _simulationDone
          ? null
          : () => _showTutorial(
              title: l10n.homeChecklistItem4Title,
              body: l10n.checklistTutorial4Body,
            ),
    ),
    _ItemSpec(
      done: _item5Done,
      title: l10n.homeChecklistItem5Title,
      infoBody: l10n.checklistInfo5Body,
      onTap: _item5Done
          ? null
          : () => _showTutorial(
              title: l10n.homeChecklistItem5Title,
              body: l10n.checklistTutorial5Body,
              goThereTarget: RouteNames.modes,
            ),
    ),
    _ItemSpec(
      done: _permissionDone,
      title: l10n.homeChecklistItem6Title,
      infoBody: l10n.checklistInfo6Body,
      onTap: _permissionDone ? null : _requestPermissionAndRefresh,
    ),
  ];

  Future<void> _navTo(
    String routeName, {
    Map<String, String> queryParameters = const <String, String>{},
  }) async {
    await context.pushNamed<void>(routeName, queryParameters: queryParameters);
    if (!mounted) return;
    await _refresh();
  }

  Future<void> _showTutorial({
    required String title,
    required String body,
    String? goThereTarget,
  }) async {
    final navigated = await ChecklistSheetContent.show(
      context,
      title: title,
      body: body,
      goThereTarget: goThereTarget,
    );
    if (!mounted) return;
    if (navigated && goThereTarget != null) {
      await context.pushNamed<void>(goThereTarget);
      if (!mounted) return;
    }
    await _refresh();
  }

  Future<void> _requestPermissionAndRefresh() async {
    final granted = await _requestPermission();
    if (!mounted) return;
    setState(() => _permissionDone = granted);
    _persistAllDoneIfNeeded();
  }
}

/// Whether [id] is one of the seeded mode ids (Walk / Date). Used to
/// distinguish "the user customized a mode" from "the seed modes still
/// exist as-is".
bool _isSeedModeId(String id) =>
    id == SeedData.walkModeId || id == SeedData.dateModeId;

/// Brief congratulations banner shown the moment the final checklist
/// item is completed (spec 04 §Safety Setup Checklist — Behavior). It
/// replaces the checklist card for the remainder of the visit;
/// [_SafetySetupChecklistState] persists a flag so it auto-dismisses on
/// the next visit. Marked as a live region so screen readers announce
/// the confirmation as it appears.
class _AllDoneBanner extends StatelessWidget {
  const _AllDoneBanner({required this.message});

  /// Localized confirmation text (`homeChecklistAllDoneBanner`).
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Card(
      key: const Key('safety-setup-all-done-banner'),
      margin: const EdgeInsets.only(bottom: 12),
      color: cs.primaryContainer,
      child: Semantics(
        liveRegion: true,
        container: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: <Widget>[
              Icon(Icons.verified, color: cs.onPrimaryContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.doneCount,
    required this.expanded,
    required this.onToggle,
    required this.onDismiss,
  });

  final int doneCount;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 4, 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(l10n.homeChecklistTitle, style: textTheme.titleMedium),
                Text(
                  l10n.homeChecklistProgress('$doneCount', '6'),
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: expanded
                ? l10n.homeChecklistCollapseTooltip
                : l10n.homeChecklistExpandTooltip,
            icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
            onPressed: onToggle,
          ),
          IconButton(
            tooltip: l10n.homeChecklistDismissTooltip,
            icon: const Icon(Icons.close),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.spec});

  final _ItemSpec spec;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textColor = spec.done
        ? cs.onSurfaceVariant
        : theme.textTheme.bodyLarge?.color;
    return ListTile(
      leading: Icon(
        spec.done ? Icons.check_circle : Icons.circle_outlined,
        color: spec.done ? cs.primary : cs.onSurfaceVariant,
      ),
      title: Text(
        spec.title,
        style: theme.textTheme.bodyLarge?.copyWith(color: textColor),
      ),
      onTap: spec.onTap,
      trailing: IconButton(
        tooltip: l10n.homeChecklistInfoTooltip,
        icon: const Icon(Icons.info_outline),
        onPressed: () => ChecklistSheetContent.showInfo(
          context,
          title: spec.title,
          body: spec.infoBody,
        ),
      ),
    );
  }
}

/// Per-row configuration consumed by [_Row]. Encapsulates the title,
/// info body, and onTap so [SafetySetupChecklist.build] stays
/// declarative.
class _ItemSpec {
  const _ItemSpec({
    required this.done,
    required this.title,
    required this.infoBody,
    required this.onTap,
  });

  final bool done;
  final String title;
  final String infoBody;
  final VoidCallback? onTap;
}

/// Shared modal layout for the checklist's "tutorial" and "info" bottom
/// sheets (spec 04 §Safety Setup Checklist — Info icons + Tutorials).
///
/// Renders a heading + body + primary action. When [goThereTarget] is
/// non-null the sheet shows a `[Go there]` primary action that pops
/// with `true` so the caller can deep-link; the dismiss action pops
/// with `false`. Tutorial-only sheets (the simulation tutorial) pass a
/// null target so only the single dismiss action shows.
class ChecklistSheetContent extends StatelessWidget {
  /// Creates a [ChecklistSheetContent].
  const ChecklistSheetContent({
    super.key,
    required this.title,
    required this.body,
    this.goThereTarget,
  });

  /// Heading at the top of the sheet.
  final String title;

  /// Body paragraph (kept under 80 words per spec).
  final String body;

  /// When non-null the sheet shows a `[Go there]` primary action; the
  /// caller deep-links to this route name when the sheet returns
  /// `true`.
  final String? goThereTarget;

  /// Convenience launcher for tutorial sheets. Returns true when the
  /// user tapped `[Go there]` so the caller can navigate; false when
  /// the sheet was dismissed.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String body,
    String? goThereTarget,
  }) async {
    final r = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext _) => ChecklistSheetContent(
        title: title,
        body: body,
        goThereTarget: goThereTarget,
      ),
    );
    return r ?? false;
  }

  /// Convenience launcher for info-only sheets. The single primary
  /// button reads "Got it" and dismisses.
  static Future<void> showInfo(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext _) =>
          ChecklistSheetContent(title: title, body: body),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(body, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.homeChecklistGotIt),
                ),
                if (goThereTarget != null) ...<Widget>[
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(l10n.homeChecklistGoThere),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
