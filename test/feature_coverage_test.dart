// Feature completeness checklist — Phase 0 skeleton.
//
// Maps every F-NNN feature ID (from
// ~/.claude/plans/make-sure-that-there-typed-tulip.md §Feature
// completeness checklist) to an implementation + test status record.
//
// Each row is initially {implemented: false, tested: false}.
// Phase N flips rows to true as it delivers the feature and tests.
//
// Phase 11 asserts: every row has implemented=true AND tested=true.

import 'package:test/test.dart';

/// Status record for a single feature.
///
/// Phase N sets [implemented] and [tested] to true when the feature and
/// its tests land. Phase 11 asserts both fields are true for every entry.
final class _FeatureStatus {
  // ignore: avoid_unused_constructor_parameters
  const _FeatureStatus({
    required this.id,
    required this.description,
    required this.phase,
    // ignore: unused_element_parameter
    this.implemented = false,
    // ignore: unused_element_parameter
    this.tested = false,
  });

  final String id;
  final String description;
  final int phase;
  final bool implemented;
  final bool tested;
}

// ignore_for_file: prefer_expression_function_bodies
const List<_FeatureStatus> _features = [
  // ── Step types (F-001..F-009) ────────────────────────────────────
  _FeatureStatus(id: 'F-001', description: 'HoldButton step', phase: 3),
  _FeatureStatus(id: 'F-002', description: 'DisguisedReminder step', phase: 3),
  _FeatureStatus(id: 'F-003', description: 'HardwareButton step', phase: 3),
  _FeatureStatus(id: 'F-004', description: 'CountdownWarning step', phase: 3),
  _FeatureStatus(
    id: 'F-005',
    description: 'FakeCall step (event-not-pause per Pivot 2)',
    phase: 3,
  ),
  _FeatureStatus(id: 'F-006', description: 'SmsContact step', phase: 3),
  _FeatureStatus(id: 'F-007', description: 'PhoneCallContact step', phase: 3),
  _FeatureStatus(id: 'F-008', description: 'LoudAlarm step', phase: 3),
  _FeatureStatus(id: 'F-009', description: 'CallEmergency step', phase: 3),

  // ── Triggers (F-010..F-016) ──────────────────────────────────────
  _FeatureStatus(
    id: 'F-010',
    description: 'Hardware-button distress (5x volume)',
    phase: 2,
  ),
  _FeatureStatus(id: 'F-011', description: 'Duress PIN trigger', phase: 5),
  _FeatureStatus(
    id: 'F-012',
    description: 'Wrong-PIN threshold trigger',
    phase: 5,
  ),
  _FeatureStatus(
    id: 'F-013',
    description: 'GPS-arrival disarm trigger',
    phase: 2,
  ),
  _FeatureStatus(id: 'F-014', description: 'Timer disarm trigger', phase: 2),
  _FeatureStatus(
    id: 'F-015',
    description: 'Low-battery alert chain (separate engine)',
    phase: 5,
  ),
  _FeatureStatus(id: 'F-016', description: 'Distress mode CRUD UI', phase: 6),

  // ── Screens (F-017..F-044) ───────────────────────────────────────
  _FeatureStatus(id: 'F-017', description: 'HomeScreen', phase: 6),
  _FeatureStatus(id: 'F-018', description: 'Onboarding (3 pages)', phase: 6),
  _FeatureStatus(id: 'F-019', description: 'SessionScreen', phase: 6),
  _FeatureStatus(id: 'F-020', description: 'FakeCallScreen', phase: 6),
  _FeatureStatus(id: 'F-021', description: 'ChainExhaustedScreen', phase: 6),
  _FeatureStatus(id: 'F-022', description: 'SimulationSummaryScreen', phase: 6),
  _FeatureStatus(id: 'F-023', description: 'ContactsListScreen', phase: 6),
  _FeatureStatus(id: 'F-024', description: 'ContactFormScreen', phase: 6),
  _FeatureStatus(id: 'F-025', description: 'SessionHistoryScreen', phase: 6),
  _FeatureStatus(id: 'F-026', description: 'SessionLogDetailScreen', phase: 6),
  _FeatureStatus(id: 'F-027', description: 'EvidenceExportScreen', phase: 6),
  _FeatureStatus(id: 'F-028', description: 'SettingsHubScreen', phase: 6),
  _FeatureStatus(id: 'F-029', description: 'SecurityScreen (3 PINs)', phase: 6),
  _FeatureStatus(id: 'F-030', description: 'PinSetupScreen', phase: 6),
  _FeatureStatus(id: 'F-031', description: 'StealthScreen', phase: 6),
  _FeatureStatus(id: 'F-032', description: 'EventDefaultsScreen', phase: 6),
  _FeatureStatus(id: 'F-033', description: 'GpsLoggingScreen', phase: 6),
  _FeatureStatus(id: 'F-034', description: 'ReminderTemplatesScreen', phase: 6),
  _FeatureStatus(id: 'F-035', description: 'BatteryAlertScreen', phase: 6),
  _FeatureStatus(id: 'F-036', description: 'HistoryRetentionScreen', phase: 6),
  _FeatureStatus(id: 'F-037', description: 'NotificationsScreen', phase: 6),
  _FeatureStatus(id: 'F-038', description: 'ProfileScreen', phase: 6),
  _FeatureStatus(id: 'F-039', description: 'ModesListScreen', phase: 6),
  _FeatureStatus(id: 'F-040', description: 'ModeEditorScreen', phase: 6),
  _FeatureStatus(id: 'F-041', description: 'StepConfigFormScreen', phase: 6),
  _FeatureStatus(id: 'F-042', description: 'AboutScreen', phase: 6),
  _FeatureStatus(id: 'F-043', description: 'FeedbackScreen', phase: 6),
  _FeatureStatus(id: 'F-044', description: 'BackupScreen', phase: 6),

  // ── Services (F-045..F-061) ──────────────────────────────────────
  _FeatureStatus(id: 'F-045', description: 'AudioService triplet', phase: 5),
  _FeatureStatus(id: 'F-046', description: 'LocationService triplet', phase: 5),
  _FeatureStatus(
    id: 'F-047',
    description: 'MessagingService (SMS/WhatsApp/Telegram + retry)',
    phase: 5,
  ),
  _FeatureStatus(id: 'F-048', description: 'PhoneService triplet', phase: 5),
  _FeatureStatus(
    id: 'F-049',
    description: 'VibrationService triplet',
    phase: 5,
  ),
  _FeatureStatus(
    id: 'F-050',
    description: 'NotificationService triplet',
    phase: 5,
  ),
  _FeatureStatus(id: 'F-051', description: 'WakeLockService triplet', phase: 5),
  _FeatureStatus(id: 'F-052', description: 'PermissionService', phase: 5),
  _FeatureStatus(id: 'F-053', description: 'FlashService triplet', phase: 5),
  _FeatureStatus(
    id: 'F-054',
    description: 'RecordingService triplet',
    phase: 5,
  ),
  _FeatureStatus(
    id: 'F-055',
    description: 'BackgroundSessionService',
    phase: 5,
  ),
  _FeatureStatus(
    id: 'F-056',
    description: 'HomeWidgetService triplet',
    phase: 5,
  ),
  _FeatureStatus(
    id: 'F-057',
    description: 'CallStateService triplet',
    phase: 5,
  ),
  _FeatureStatus(id: 'F-058', description: 'SimulationAudioService', phase: 5),
  _FeatureStatus(
    id: 'F-059',
    description: 'SimulationLocationService',
    phase: 5,
  ),
  _FeatureStatus(
    id: 'F-060',
    description: 'SimulationMessagingService',
    phase: 5,
  ),
  _FeatureStatus(
    id: 'F-061',
    description: 'SentryService (day 1 per D2)',
    phase: 5,
  ),

  // ── Settings & defaults (F-062..F-072) ──────────────────────────
  _FeatureStatus(id: 'F-062', description: 'App PIN', phase: 5),
  _FeatureStatus(id: 'F-063', description: 'Session End PIN', phase: 5),
  _FeatureStatus(id: 'F-064', description: 'Duress PIN', phase: 5),
  _FeatureStatus(
    id: 'F-065',
    description: 'Theme (light/dark/system)',
    phase: 6,
  ),
  _FeatureStatus(id: 'F-066', description: 'Language (14 locales)', phase: 8),
  _FeatureStatus(
    id: 'F-067',
    description: 'EmergencyNumber (full country map)',
    phase: 6,
  ),
  _FeatureStatus(id: 'F-068', description: 'AlarmDND override', phase: 6),
  _FeatureStatus(id: 'F-069', description: 'Biometric flags (3)', phase: 6),
  _FeatureStatus(
    id: 'F-070',
    description: 'Telemetry opt-out (Sentry)',
    phase: 5,
  ),
  _FeatureStatus(
    id: 'F-071',
    description: 'Launch auth (app PIN on cold start)',
    phase: 6,
  ),
  _FeatureStatus(id: 'F-072', description: 'Alarm gradual volume', phase: 6),

  // ── Localization (F-073..F-086) ──────────────────────────────────
  _FeatureStatus(id: 'F-073', description: 'ARB: en', phase: 8),
  _FeatureStatus(id: 'F-074', description: 'ARB: de', phase: 8),
  _FeatureStatus(id: 'F-075', description: 'ARB: es', phase: 8),
  _FeatureStatus(id: 'F-076', description: 'ARB: fr', phase: 8),
  _FeatureStatus(id: 'F-077', description: 'ARB: ru', phase: 8),
  _FeatureStatus(id: 'F-078', description: 'ARB: zh', phase: 8),
  _FeatureStatus(id: 'F-079', description: 'ARB: zh_TW', phase: 8),
  _FeatureStatus(id: 'F-080', description: 'ARB: hi', phase: 8),
  _FeatureStatus(id: 'F-081', description: 'ARB: fa (RTL)', phase: 8),
  _FeatureStatus(id: 'F-082', description: 'ARB: uk', phase: 8),
  _FeatureStatus(id: 'F-083', description: 'ARB: pl', phase: 8),
  _FeatureStatus(id: 'F-084', description: 'ARB: el', phase: 8),
  _FeatureStatus(id: 'F-085', description: 'ARB: ar (RTL)', phase: 8),
  _FeatureStatus(id: 'F-086', description: 'ARB: he (RTL)', phase: 8),

  // ── Engine & data (F-087..F-100) ─────────────────────────────────
  _FeatureStatus(id: 'F-087', description: 'Pure-Dart SessionEngine', phase: 2),
  _FeatureStatus(
    id: 'F-088',
    description: 'Speed multipliers (fg/bg caps)',
    phase: 2,
  ),
  _FeatureStatus(id: 'F-089', description: 'Jitter ±20%', phase: 2),
  _FeatureStatus(id: 'F-090', description: 'Pause/resume', phase: 2),
  _FeatureStatus(id: 'F-091', description: 'Session logging', phase: 5),
  _FeatureStatus(id: 'F-092', description: 'Log export', phase: 6),
  _FeatureStatus(
    id: 'F-093',
    description: 'Seed modes (Walk + Date + Distress)',
    phase: 4,
  ),
  _FeatureStatus(id: 'F-094', description: 'ModeOverrides', phase: 4),
  _FeatureStatus(id: 'F-095', description: 'Contact CRUD', phase: 4),
  _FeatureStatus(id: 'F-096', description: 'AppDefaults', phase: 4),
  _FeatureStatus(id: 'F-097', description: 'UserProfile', phase: 4),
  _FeatureStatus(
    id: 'F-098',
    description: 'Encryption (sqlite3mc + flutter_secure_storage)',
    phase: 4,
  ),
  _FeatureStatus(id: 'F-099', description: 'Backup', phase: 6),
  _FeatureStatus(
    id: 'F-100',
    description: 'SessionEnd (PIN + QuickExit)',
    phase: 6,
  ),

  // ── Widgets (F-101..F-115) ───────────────────────────────────────
  _FeatureStatus(id: 'F-101', description: 'PageIndicator widget', phase: 6),
  _FeatureStatus(id: 'F-102', description: 'ModeSelector widget', phase: 6),
  _FeatureStatus(id: 'F-103', description: 'ContactChips widget', phase: 6),
  _FeatureStatus(id: 'F-104', description: 'HoldButton (3 styles)', phase: 6),
  _FeatureStatus(
    id: 'F-105',
    description: 'DisguisedReminderOverlay widget',
    phase: 6,
  ),
  _FeatureStatus(id: 'F-106', description: 'CountdownWarning widget', phase: 6),
  _FeatureStatus(id: 'F-107', description: 'FakeCallScreen widget', phase: 6),
  _FeatureStatus(
    id: 'F-108',
    description: 'TimingSlider (DE-1 promoted)',
    phase: 6,
  ),
  _FeatureStatus(id: 'F-109', description: 'InfoIconButton widget', phase: 6),
  _FeatureStatus(id: 'F-110', description: 'SettingsTile widget', phase: 6),
  _FeatureStatus(
    id: 'F-111',
    description: 'MoreSettingsPanel (DE-4 promoted)',
    phase: 6,
  ),
  _FeatureStatus(
    id: 'F-112',
    description: 'SwipeSlider (disarm confirm)',
    phase: 6,
  ),
  _FeatureStatus(
    id: 'F-113',
    description: 'SessionScreenTimer (3 display modes)',
    phase: 6,
  ),
  _FeatureStatus(
    id: 'F-114',
    description: 'SimulationControlsBar widget',
    phase: 6,
  ),
  _FeatureStatus(id: 'F-115', description: 'SIMWatermark widget', phase: 6),

  // ── Seed data (F-116..F-120) ─────────────────────────────────────
  _FeatureStatus(id: 'F-116', description: 'WalkMode seed', phase: 4),
  _FeatureStatus(id: 'F-117', description: 'DateMode seed', phase: 4),
  _FeatureStatus(
    id: 'F-118',
    description: 'DefaultDistressMode seed',
    phase: 4,
  ),
  _FeatureStatus(id: 'F-119', description: '8 reminder templates', phase: 4),
  _FeatureStatus(id: 'F-120', description: 'EventDefaults seed', phase: 4),

  // ── Native channels (F-121..F-127) ──────────────────────────────
  _FeatureStatus(
    id: 'F-121',
    description: 'SmsWorkManager retry queue (Android)',
    phase: 7,
  ),
  _FeatureStatus(
    id: 'F-122',
    description: 'CallStateListener (Android + iOS)',
    phase: 7,
  ),
  _FeatureStatus(id: 'F-123', description: 'DeviceNumberReader', phase: 7),
  _FeatureStatus(
    id: 'F-124',
    description: 'AndroidAppWidget (DE-5 Android promoted)',
    phase: 7,
  ),
  _FeatureStatus(
    id: 'F-125',
    description: 'iOSWidgetKit (DE-5 iOS promoted per D14)',
    phase: 7,
  ),
  _FeatureStatus(
    id: 'F-126',
    description: 'CameraFlashlight channel',
    phase: 7,
  ),
  _FeatureStatus(id: 'F-127', description: 'ScreenFlash channel', phase: 7),

  // ── Tests (F-128..F-139) ─────────────────────────────────────────
  _FeatureStatus(id: 'F-128', description: 'Engine unit tests', phase: 2),
  _FeatureStatus(id: 'F-129', description: 'Strategy unit tests', phase: 3),
  _FeatureStatus(
    id: 'F-130',
    description: 'Model unit tests',
    phase: 1,
    implemented: true,
    tested: true,
  ),
  _FeatureStatus(id: 'F-131', description: 'Widget tests per screen', phase: 6),
  _FeatureStatus(
    id: 'F-132',
    description: 'Golden tests (visual-critical screens)',
    phase: 6,
  ),
  _FeatureStatus(
    id: 'F-133',
    description: 'Integration end-to-end tests',
    phase: 9,
  ),
  _FeatureStatus(
    id: 'F-134',
    description: 'Property tests (JSON round-trip)',
    phase: 1,
    implemented: true,
    tested: true,
  ),
  _FeatureStatus(
    id: 'F-135',
    description: 'Wiring-map coverage test',
    phase: 5,
  ),
  _FeatureStatus(
    id: 'F-136',
    description: 'Spec coverage matrix test',
    phase: 9,
  ),
  _FeatureStatus(id: 'F-137', description: 'Simulation-swap test', phase: 5),
  _FeatureStatus(
    id: 'F-138',
    description: 'Feature coverage matrix test',
    phase: 0,
  ),
  _FeatureStatus(id: 'F-139', description: 'Regression test suite', phase: 9),

  // ── Promoted DE-* (F-140..F-145) ─────────────────────────────────
  _FeatureStatus(
    id: 'F-140',
    description: 'DE-1 TimingSlider (logarithmic)',
    phase: 6,
  ),
  _FeatureStatus(
    id: 'F-141',
    description: 'DE-2 LogGpsOverride per-step',
    phase: 1,
    implemented: true,
  ),
  _FeatureStatus(
    id: 'F-142',
    description: 'DE-3 IntervalTracking (GpsLoggingConfig)',
    phase: 5,
  ),
  _FeatureStatus(id: 'F-143', description: 'DE-4 MoreSettingsPanel', phase: 6),
  _FeatureStatus(
    id: 'F-144',
    description: 'DE-5 Android home widget',
    phase: 7,
  ),
  _FeatureStatus(
    id: 'F-145',
    description: 'DE-5 iOS WidgetKit (promoted per D14)',
    phase: 7,
  ),

  // ── Spec-audit runtime items (F-146..F-150) ──────────────────────
  _FeatureStatus(
    id: 'F-146',
    description: 'Session locks (no re-entry during active session)',
    phase: 2,
  ),
  _FeatureStatus(
    id: 'F-147',
    description: 'HardwareButton-as-step OR trigger validator',
    phase: 2,
  ),
  _FeatureStatus(
    id: 'F-148',
    description: 'distressModeId validator (references valid mode)',
    phase: 4,
  ),
  _FeatureStatus(
    id: 'F-149',
    description: 'PIN auto-submit hashing (4–8 digits)',
    phase: 5,
  ),
  _FeatureStatus(
    id: 'F-150',
    description: 'Offline-first architecture (no server dependency)',
    phase: 9,
  ),
];

void main() {
  group('Feature coverage matrix (Phase 0 skeleton)', () {
    test('Feature list has ≥ 150 entries', () {
      expect(_features.length, greaterThanOrEqualTo(150));
    });

    test('Every feature has a non-empty id and description', () {
      for (final f in _features) {
        expect(f.id, isNotEmpty, reason: 'Empty id found');
        expect(
          f.description,
          isNotEmpty,
          reason: '${f.id} has empty description',
        );
      }
    });

    test('Feature IDs are unique', () {
      final ids = _features.map((f) => f.id).toList();
      final unique = ids.toSet();
      expect(ids.length, unique.length, reason: 'Duplicate feature IDs found');
    });

    test('F-138 (this file) is in the list', () {
      final f138 = _features.where((f) => f.id == 'F-138').toList();
      expect(f138.length, 1);
    });

    // Phase 11 assertion (currently commented — uncomment when all
    // phases have landed):
    //
    // test('All features are implemented and tested (Phase 11 gate)', () {
    //   final incomplete = _features
    //       .where((f) => !f.implemented || !f.tested)
    //       .map((f) => f.id)
    //       .toList();
    //   expect(incomplete, isEmpty,
    //       reason: 'Features not yet implemented+tested: $incomplete');
    // });
  });
}
