/// User-profile edit form.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/domain/models/user_profile.dart';
import 'package:guardianangela/features/profile/profile_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Profile screen.
class ProfileScreen extends ConsumerStatefulWidget {
  /// Creates the profile screen.
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _physicalCtrl = TextEditingController();
  final _bloodCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _medicationsCtrl = TextEditingController();
  final _conditionsCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();
  bool _hydrated = false;

  void _hydrate(UserProfile? profile) {
    if (_hydrated) return;
    _hydrated = true;
    if (profile == null) return;
    _nameCtrl.text = profile.name ?? '';
    _ageCtrl.text = profile.age?.toString() ?? '';
    _phoneCtrl.text = profile.phoneNumber ?? '';
    _physicalCtrl.text = profile.physicalDescription ?? '';
    _bloodCtrl.text = profile.bloodType ?? '';
    _allergiesCtrl.text = profile.allergies ?? '';
    _medicationsCtrl.text = profile.medications ?? '';
    _conditionsCtrl.text = profile.medicalConditions ?? '';
    _instructionsCtrl.text = profile.emergencyInstructions ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _phoneCtrl.dispose();
    _physicalCtrl.dispose();
    _bloodCtrl.dispose();
    _allergiesCtrl.dispose();
    _medicationsCtrl.dispose();
    _conditionsCtrl.dispose();
    _instructionsCtrl.dispose();
    super.dispose();
  }

  /// Word-boundary case-insensitive check for "angela" / "angelas".
  /// Spec 06 §"Angela" Safety Keyword: a name containing the
  /// "Ask for Angela" code-word as a standalone word would clash
  /// with the safety convention if used as a real personal name,
  /// so we warn the user before persisting.
  static final RegExp _angelaPattern =
      RegExp(r'\bangelas?\b', caseSensitive: false);

  String? _nonEmpty(String raw) {
    final v = raw.trim();
    return v.isEmpty ? null : v;
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isNotEmpty && _angelaPattern.hasMatch(name)) {
      final l = AppLocalizations.of(context);
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.profileAngelaWarningTitle),
          content: Text(l.profileAngelaWarningBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l.commonOk),
            ),
          ],
        ),
      );
      if (ok != true) return;
      if (!mounted) return;
    }
    final profile = UserProfile(
      name: name.isEmpty ? null : name,
      age: int.tryParse(_ageCtrl.text),
      phoneNumber: _nonEmpty(_phoneCtrl.text),
      physicalDescription: _nonEmpty(_physicalCtrl.text),
      bloodType: _nonEmpty(_bloodCtrl.text),
      allergies: _nonEmpty(_allergiesCtrl.text),
      medications: _nonEmpty(_medicationsCtrl.text),
      medicalConditions: _nonEmpty(_conditionsCtrl.text),
      emergencyInstructions: _nonEmpty(_instructionsCtrl.text),
    );
    await ref.read(profileControllerProvider.notifier).save(profile);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final profileAsync = ref.watch(profileControllerProvider);
    if (!_hydrated) {
      profileAsync.whenData(_hydrate);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(l.profileTitle),
        actions: [IconButton(onPressed: _save, icon: const Icon(Icons.check))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(labelText: l.profileFieldName),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ageCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l.profileFieldAge),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: l.profileFieldPhoneNumber,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _physicalCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l.profileFieldPhysicalDescription,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bloodCtrl,
            decoration: InputDecoration(labelText: l.profileFieldBloodType),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _allergiesCtrl,
            maxLines: 3,
            decoration: InputDecoration(labelText: l.profileFieldAllergies),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _medicationsCtrl,
            maxLines: 3,
            decoration: InputDecoration(labelText: l.profileFieldMedications),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _conditionsCtrl,
            maxLines: 3,
            decoration: InputDecoration(labelText: l.profileFieldConditions),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _instructionsCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: l.profileFieldInstructions,
            ),
          ),
        ],
      ),
    );
  }
}
