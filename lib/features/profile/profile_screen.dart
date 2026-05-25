import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/features/profile/profile_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// User profile editor.
///
/// All fields auto-save on submit. See spec 04 §Profile Editor.
class ProfileScreen extends ConsumerStatefulWidget {
  /// Creates a [ProfileScreen].
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _descCtl = TextEditingController();
  final _ageCtl = TextEditingController();
  final _bloodCtl = TextEditingController();
  final _allergiesCtl = TextEditingController();
  final _medsCtl = TextEditingController();
  final _conditionsCtl = TextEditingController();
  final _instrCtl = TextEditingController();
  bool _initialised = false;

  @override
  void dispose() {
    _nameCtl.dispose();
    _phoneCtl.dispose();
    _descCtl.dispose();
    _ageCtl.dispose();
    _bloodCtl.dispose();
    _allergiesCtl.dispose();
    _medsCtl.dispose();
    _conditionsCtl.dispose();
    _instrCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stateAsync = ref.watch(profileControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(child: Text('Error: $e')),
        data: (state) {
          if (!_initialised) {
            _nameCtl.text = state.profile.name ?? '';
            _phoneCtl.text = state.profile.phoneNumber ?? '';
            _descCtl.text = state.profile.physicalDescription ?? '';
            _ageCtl.text = state.profile.age?.toString() ?? '';
            _bloodCtl.text = state.profile.bloodType ?? '';
            _allergiesCtl.text = state.profile.allergies ?? '';
            _medsCtl.text = state.profile.medications ?? '';
            _conditionsCtl.text = state.profile.medicalConditions ?? '';
            _instrCtl.text = state.profile.emergencyInstructions ?? '';
            _initialised = true;
          }
          final notifier = ref.read(profileControllerProvider.notifier);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              TextField(
                controller: _nameCtl,
                decoration: InputDecoration(labelText: l10n.profileFieldName),
                onSubmitted: (String v) => notifier.patch(name: v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneCtl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: l10n.profileFieldPhone),
                onSubmitted: (String v) => notifier.patch(phoneNumber: v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _ageCtl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.profileFieldAge),
                onSubmitted: (String v) => notifier.patch(age: int.tryParse(v)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descCtl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.profileFieldDescription,
                ),
                onSubmitted: (String v) =>
                    notifier.patch(physicalDescription: v),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _bloodCtl,
                decoration: InputDecoration(
                  labelText: l10n.profileFieldBloodType,
                ),
                onSubmitted: (String v) => notifier.patch(bloodType: v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _allergiesCtl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l10n.profileFieldAllergies,
                ),
                onSubmitted: (String v) => notifier.patch(allergies: v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _medsCtl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l10n.profileFieldMedications,
                ),
                onSubmitted: (String v) => notifier.patch(medications: v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _conditionsCtl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l10n.profileFieldMedicalConditions,
                ),
                onSubmitted: (String v) => notifier.patch(medicalConditions: v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _instrCtl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.profileFieldEmergencyInstructions,
                ),
                onSubmitted: (String v) =>
                    notifier.patch(emergencyInstructions: v),
              ),
            ],
          );
        },
      ),
    );
  }
}
