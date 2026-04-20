/// Fake incoming-call overlay.
///
/// Presents Answer / Decline / Hang-up buttons wired to
/// [FakeCallController]. Used as a safety pretext during fakeCall
/// escalation steps.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/features/fake_call/fake_call_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Simulated incoming-call overlay.
class FakeCallScreen extends ConsumerStatefulWidget {
  /// Creates the fake-call screen.
  const FakeCallScreen({super.key});

  @override
  ConsumerState<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends ConsumerState<FakeCallScreen> {
  bool _answered = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = ref.read(fakeCallControllerProvider.notifier);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              l.fakeCallTitle,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Colors.white),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!_answered) ...[
                  _CallButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    label: l.fakeCallDecline,
                    onTap: () async {
                      await controller.decline();
                      if (context.mounted) context.pop();
                    },
                  ),
                  _CallButton(
                    icon: Icons.call,
                    color: Colors.green,
                    label: l.fakeCallAnswer,
                    onTap: () async {
                      await controller.answer();
                      setState(() => _answered = true);
                    },
                  ),
                ] else
                  _CallButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    label: l.fakeCallHangUp,
                    onTap: () async {
                      await controller.hangUp();
                      if (context.mounted) context.pop();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      );
}
