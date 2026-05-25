import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// In-app feedback form.
///
/// Opens a `mailto:` link with the feedback prefilled. Local persistence
/// to a `feedback_history` table is out of scope for Phase 6 (no DAO
/// exists yet) — the email path is the documented secondary in spec
/// 06 §Feedback.
class FeedbackFormScreen extends StatefulWidget {
  /// Creates a [FeedbackFormScreen].
  const FeedbackFormScreen({super.key});

  @override
  State<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> {
  String _category = 'bug';
  final _emailCtl = TextEditingController();
  final _messageCtl = TextEditingController();
  bool _includeLog = false;

  @override
  void dispose() {
    _emailCtl.dispose();
    _messageCtl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context);
    if (_messageCtl.text.trim().length < 10) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.feedbackMessageRequired)));
      return;
    }
    final body = StringBuffer()
      ..writeln('Category: $_category')
      ..writeln('Email: ${_emailCtl.text.trim()}')
      ..writeln('Include log: $_includeLog')
      ..writeln()
      ..writeln(_messageCtl.text.trim());
    final uri = Uri(
      scheme: 'mailto',
      path: 'guardian.angela.app@gmail.com',
      queryParameters: <String, String>{
        'subject': 'Guardian Angela feedback ($_category)',
        'body': body.toString(),
      },
    );
    await launchUrl(uri);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.feedbackSent)));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.feedbackTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text(
              l10n.feedbackHeading,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: InputDecoration(
                labelText: l10n.feedbackCategoryLabel,
              ),
              onChanged: (String? v) {
                if (v != null) setState(() => _category = v);
              },
              items: <DropdownMenuItem<String>>[
                DropdownMenuItem(
                  value: 'bug',
                  child: Text(l10n.feedbackCategoryBug),
                ),
                DropdownMenuItem(
                  value: 'feature',
                  child: Text(l10n.feedbackCategoryFeature),
                ),
                DropdownMenuItem(
                  value: 'other',
                  child: Text(l10n.feedbackCategoryOther),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailCtl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: l10n.feedbackEmailLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageCtl,
              maxLines: 5,
              decoration: InputDecoration(labelText: l10n.feedbackMessageLabel),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: Text(l10n.feedbackIncludeLog),
              value: _includeLog,
              onChanged: (bool v) => setState(() => _includeLog = v),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _send,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(l10n.feedbackSend),
            ),
          ],
        ),
      ),
    );
  }
}
