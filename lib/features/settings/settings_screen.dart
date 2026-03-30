import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safewayhome/l10n/app_localizations.dart';

import '../../core/constants/route_names.dart';
import '../../core/theme/pride_widgets.dart';
import 'settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _languages = {
    'en': 'English',
    'de': 'Deutsch',
    'fr': 'Français',
    'es': 'Español',
    'ru': 'Русский',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        bottom: const PrideAppBarBottom(),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (settings) => ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 12),
            // Theme toggle
            SwitchListTile(
              title: Text(l10n.darkTheme),
              value: settings.isDarkTheme,
              onChanged: (_) {
                ref
                    .read(settingsControllerProvider.notifier)
                    .toggleTheme();
              },
              secondary: Icon(
                settings.isDarkTheme ? Icons.dark_mode : Icons.light_mode,
              ),
            ),
            const PrideDivider(),

            // Language picker
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.language),
              subtitle: Text(_languages[settings.languageCode] ?? settings.languageCode),
              onTap: () => _showLanguagePicker(context, ref, settings.languageCode),
            ),
            const PrideDivider(),

            // Emergency number
            ListTile(
              leading: const Icon(Icons.emergency),
              title: Text(l10n.emergencyNumber),
              subtitle: Text(settings.emergencyNumber),
              onTap: () => _showEmergencyNumberDialog(
                context,
                ref,
                settings.emergencyNumber,
              ),
            ),
            const PrideDivider(),
            const SizedBox(height: 24),

            // Navigation items
            ListTile(
              leading: const Icon(Icons.timeline),
              title: Text(l10n.escalationChain),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(RouteNames.escalationSettings),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.notifications_active),
              title: Text(l10n.reminderTemplates),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(RouteNames.reminderTemplates),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.tune),
              title: Text(l10n.modes),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(RouteNames.modes),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.phone_callback),
              title: Text(l10n.fakeCallSettings),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(RouteNames.fakeCallSettings),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(
    BuildContext context,
    WidgetRef ref,
    String currentCode,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        return SimpleDialog(
          title: Text(l10n.language),
          children: [
            RadioGroup<String>(
              groupValue: currentCode,
              onChanged: (code) {
                if (code == null) return;
                ref
                    .read(settingsControllerProvider.notifier)
                    .setLanguage(code);
                Navigator.of(ctx).pop();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _languages.entries.map((entry) {
                  return RadioListTile<String>(
                    title: Text(entry.value),
                    value: entry.key,
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEmergencyNumberDialog(
    BuildContext context,
    WidgetRef ref,
    String currentNumber,
  ) {
    final controller = TextEditingController(text: currentNumber);
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(l10n.emergencyNumber),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: '112',
              labelText: l10n.emergencyNumber,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                final number = controller.text.trim();
                if (number.isNotEmpty) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setEmergencyNumber(number);
                }
                Navigator.of(ctx).pop();
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }
}
