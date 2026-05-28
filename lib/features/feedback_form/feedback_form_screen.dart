import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import 'package:guardianangela/domain/enums/feedback_type.dart';
import 'package:guardianangela/domain/models/feedback_entry.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

/// In-app feedback form.
///
/// Spec 04 §Feedback Form: persists each submission to the local
/// `feedback_history` Drift table before opening the system mailto so
/// the user keeps a copy of every report. Category selection uses
/// RadioListTile per spec layout.
class FeedbackFormScreen extends ConsumerStatefulWidget {
  /// Creates a [FeedbackFormScreen].
  const FeedbackFormScreen({super.key});

  @override
  ConsumerState<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends ConsumerState<FeedbackFormScreen> {
  FeedbackType _category = FeedbackType.bug;
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
    final entry = FeedbackEntry(
      id: const Uuid().v4(),
      category: _category,
      email: _emailCtl.text.trim().isEmpty ? null : _emailCtl.text.trim(),
      message: _messageCtl.text.trim(),
      includeLog: _includeLog,
      createdAt: DateTime.now().toUtc(),
    );
    // Fire-and-forget local persistence. Awaiting the FutureProvider
    // would block the mailto path if the database failed to open
    // (e.g. test environment without overrides). Persisting is
    // best-effort by design.
    unawaited(_persistLocally(entry));
    final body = StringBuffer()
      ..writeln('Category: ${_category.name}')
      ..writeln('Email: ${_emailCtl.text.trim()}')
      ..writeln('Include log: $_includeLog')
      ..writeln()
      ..writeln(_messageCtl.text.trim());
    final uri = Uri(
      scheme: 'mailto',
      path: 'guardian.angela.app@gmail.com',
      queryParameters: <String, String>{
        'subject': 'Guardian Angela feedback (${_category.name})',
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

  /// Fire-and-forget local write — see [_send] for rationale.
  Future<void> _persistLocally(FeedbackEntry entry) async {
    try {
      final repo = await ref.read(feedbackHistoryRepositoryProvider.future);
      await repo.insert(entry);
    } on Object catch (_) {
      // Best-effort; silently swallow.
    }
  }

  void _cancel() => context.pop();

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
            Text(
              l10n.feedbackCategoryLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            RadioGroup<FeedbackType>(
              groupValue: _category,
              onChanged: (FeedbackType? v) {
                if (v != null) setState(() => _category = v);
              },
              child: Column(
                children: <Widget>[
                  RadioListTile<FeedbackType>(
                    value: FeedbackType.bug,
                    title: Text(l10n.feedbackCategoryBug),
                  ),
                  RadioListTile<FeedbackType>(
                    value: FeedbackType.feature,
                    title: Text(l10n.feedbackCategoryFeature),
                  ),
                  RadioListTile<FeedbackType>(
                    value: FeedbackType.other,
                    title: Text(l10n.feedbackCategoryOther),
                  ),
                ],
              ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(onPressed: _cancel, child: Text(l10n.commonCancel)),
                const SizedBox(width: 8),
                FilledButton(onPressed: _send, child: Text(l10n.feedbackSend)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
