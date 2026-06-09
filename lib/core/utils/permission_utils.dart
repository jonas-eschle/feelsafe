/// Shared notification-permission helper (spec 04:461 + 10:90, Extra 42).
///
/// `ensureNotificationPermission` is the single entry point used by the
/// three callers the spec mandates:
/// 1. the session-start flow on the home screen (`HomeScreen._onStart`),
/// 2. the notification-settings re-ask block
///    (`NotificationsSettingsScreen`), and
/// 3. the home Safety-Setup-Checklist item 6 (Grant required permissions).
///
/// Centralising the logic here removes the duplicated re-ask blocks those
/// callers previously carried.
///
/// Behaviour, gated on `Theme.of(context).platform` so it is host-testable:
/// - **iOS** — a no-op that returns `true`. Notification permission is
///   granted at install time on iOS; there is nothing to re-ask
///   (spec 10:90 "iOS grants at install time, no re-ask needed").
/// - **Android 13+** (`POST_NOTIFICATIONS`):
///   - already granted → returns `true` without any dialog;
///   - denied but **not** permanent → shows a rationale dialog; if the
///     user proceeds, calls `Permission.notification.request()` (the OS
///     prompt) and returns whether it was granted; if the user declines
///     the rationale, returns `false` without prompting;
///   - **permanently** denied → shows a dialog offering a deep-link to the
///     app's system notification settings (`openAppSettings()`); on return
///     re-reads the status and returns whether it is now granted.
library;

import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Ensures the Android `POST_NOTIFICATIONS` runtime permission, re-asking
/// with a rationale (or a system-settings deep-link) when appropriate.
///
/// Returns `true` when notifications are (or become) granted, or when the
/// platform does not gate notifications behind a runtime permission (iOS).
/// Returns `false` when the user declines or leaves the permission off.
///
/// [statusReader], [requester], and [settingsOpener] exist purely as test
/// seams; production code leaves them at their defaults, which delegate to
/// `package:permission_handler`. The defaults are assigned inside the body
/// (never as default parameter values) so the function stays Flutter-only
/// at the signature level.
Future<bool> ensureNotificationPermission(
  BuildContext context, {
  Future<PermissionStatus> Function()? statusReader,
  Future<PermissionStatus> Function()? requester,
  Future<bool> Function()? settingsOpener,
}) async {
  // iOS (and any non-Android host) — notifications are granted at install
  // time; nothing to re-ask. Gate on the Theme platform so widget tests can
  // drive both branches with `ThemeData(platform:)`.
  if (Theme.of(context).platform != TargetPlatform.android) {
    return true;
  }

  final readStatus = statusReader ?? () => Permission.notification.status;
  final request = requester ?? () => Permission.notification.request();
  final openSettings = settingsOpener ?? openAppSettings;

  final status = await readStatus();
  if (status.isGranted) {
    return true;
  }

  if (!context.mounted) return false;
  final l10n = AppLocalizations.of(context);

  if (status.isPermanentlyDenied) {
    // Permanently denied: the OS will no longer show the prompt, so offer a
    // deep-link into the app's notification settings instead.
    final proceed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => _NotifPermissionDialog(
        title: l10n.permissionNotifDeniedTitle,
        body: l10n.permissionNotifDeniedBody,
        confirmLabel: l10n.permissionNotifOpenSettings,
        dismissLabel: l10n.permissionNotifNotNow,
      ),
    );
    if (proceed != true) return false;
    await openSettings();
    // Re-read after the user returns from system settings.
    final after = await readStatus();
    return after.isGranted;
  }

  // Denied but not permanent: explain why, then re-request via the OS prompt.
  final proceed = await showDialog<bool>(
    context: context,
    builder: (BuildContext ctx) => _NotifPermissionDialog(
      title: l10n.permissionNotifRationaleTitle,
      body: l10n.permissionNotifRationaleBody,
      confirmLabel: l10n.permissionNotifAllow,
      dismissLabel: l10n.permissionNotifNotNow,
    ),
  );
  if (proceed != true) return false;

  final result = await request();
  return result.isGranted;
}

/// Rationale / deep-link dialog used by [ensureNotificationPermission].
///
/// Pops `true` from the confirm action (proceed to the OS prompt or to
/// system settings) and `false` from the dismiss action or a barrier tap.
class _NotifPermissionDialog extends StatelessWidget {
  const _NotifPermissionDialog({
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.dismissLabel,
  });

  final String title;
  final String body;
  final String confirmLabel;
  final String dismissLabel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(dismissLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
