import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:go_router/go_router.dart';

import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Full-screen fake-call UI.
///
/// Locks orientation to portrait (D3). Disables back navigation
/// (PopScope) so the user must explicitly answer or decline. See spec 04
/// §Fake Call Screen.
class FakeCallScreen extends StatefulWidget {
  /// Creates a [FakeCallScreen].
  const FakeCallScreen({super.key});

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  l10n.fakeCallTitle,
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 24),
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(
                    Icons.person,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.fakeCallUnknownCaller,
                  style: textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                if (_answered)
                  FilledButton.icon(
                    icon: const Icon(Icons.call_end),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size.fromHeight(56),
                    ),
                    onPressed: () => context.pop(),
                    label: Text(l10n.fakeCallHangUp),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      _CallActionButton(
                        color: Colors.red,
                        icon: Icons.call_end,
                        label: l10n.fakeCallDecline,
                        onPressed: () => context.pop(),
                      ),
                      _CallActionButton(
                        color: Colors.green,
                        icon: Icons.call,
                        label: l10n.fakeCallAnswer,
                        onPressed: () => setState(() => _answered = true),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CallActionButton extends StatelessWidget {
  const _CallActionButton({
    required this.color,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        FloatingActionButton.large(
          heroTag: label,
          backgroundColor: color,
          onPressed: onPressed,
          child: Icon(icon, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
