import 'package:flutter/material.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:guardianangela/core/theme/guardian_angela_logo.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// About screen.
///
/// Reads version via `package_info_plus`. External links open via
/// `url_launcher`. See spec 04 §About Screen.
class AboutScreen extends StatefulWidget {
  /// Creates an [AboutScreen].
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _version = info.version);
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            const Center(child: GuardianAngelaLogo()),
            const SizedBox(height: 12),
            Center(child: Text(l10n.appTitle, style: textTheme.titleLarge)),
            Center(child: Text(l10n.homeTagline, style: textTheme.bodyMedium)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.tag),
              title: Text(l10n.aboutVersion(_version.isEmpty ? '?' : _version)),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(l10n.aboutAuthor),
            ),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: Text(l10n.aboutEmail),
              onTap: () => _open('mailto:guardian.angela.app@gmail.com'),
            ),
            const Divider(),
            ListTile(
              title: Text(l10n.aboutPrivacyPolicy),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _open('https://guardianangela.app/legal/privacy'),
            ),
            ListTile(
              title: Text(l10n.aboutTermsOfService),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _open('https://guardianangela.app/legal/terms'),
            ),
            ListTile(
              title: Text(l10n.aboutSourceCode),
              trailing: const Icon(Icons.open_in_new),
              onTap: () =>
                  _open('https://github.com/jonas-eschle/guardianangela'),
            ),
            ListTile(
              title: Text(l10n.aboutSupport),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _open('https://github.com/sponsors/jonas-eschle'),
            ),
            ListTile(
              title: Text(l10n.aboutLicenses),
              onTap: () => showLicensePage(
                context: context,
                applicationName: 'Guardian Angela',
                applicationVersion: _version,
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.aboutTagline,
                style: textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
