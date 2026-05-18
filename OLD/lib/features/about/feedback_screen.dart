/// Feedback form.
library;

import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Feedback screen.
class FeedbackScreen extends StatefulWidget {
  /// Creates the feedback screen.
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _openEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'feedback@guardianangela.app',
      queryParameters: <String, String>{
        'subject': 'Guardian Angela feedback',
        'body': _ctrl.text,
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.feedbackTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.feedbackBody),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              maxLines: 8,
              decoration: InputDecoration(labelText: l.feedbackFieldMessage),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _openEmail,
              icon: const Icon(Icons.email),
              label: Text(l.feedbackSend),
            ),
          ],
        ),
      ),
    );
  }
}
