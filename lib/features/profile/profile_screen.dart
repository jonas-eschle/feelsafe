import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/features/profile/profile_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// User profile editor.
///
/// All fields auto-save when the field loses focus (spec 04 §Profile
/// Editor: "auto-save on blur"). A [FocusNode] listener fires the
/// controller's `patch(...)` when focus exits the field.
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

  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _descFocus = FocusNode();
  final _ageFocus = FocusNode();
  final _bloodFocus = FocusNode();
  final _allergiesFocus = FocusNode();
  final _medsFocus = FocusNode();
  final _conditionsFocus = FocusNode();
  final _instrFocus = FocusNode();

  bool _initialised = false;

  @override
  void initState() {
    super.initState();
    _nameFocus.addListener(_onNameBlur);
    _phoneFocus.addListener(_onPhoneBlur);
    _descFocus.addListener(_onDescBlur);
    _ageFocus.addListener(_onAgeBlur);
    _bloodFocus.addListener(_onBloodBlur);
    _allergiesFocus.addListener(_onAllergiesBlur);
    _medsFocus.addListener(_onMedsBlur);
    _conditionsFocus.addListener(_onConditionsBlur);
    _instrFocus.addListener(_onInstrBlur);
  }

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

    _nameFocus.dispose();
    _phoneFocus.dispose();
    _descFocus.dispose();
    _ageFocus.dispose();
    _bloodFocus.dispose();
    _allergiesFocus.dispose();
    _medsFocus.dispose();
    _conditionsFocus.dispose();
    _instrFocus.dispose();
    super.dispose();
  }

  ProfileController? get _notifier {
    final state = ref.read(profileControllerProvider);
    if (!state.hasValue) return null;
    return ref.read(profileControllerProvider.notifier);
  }

  void _onNameBlur() {
    if (!_nameFocus.hasFocus) _notifier?.patch(name: _nameCtl.text);
  }

  void _onPhoneBlur() {
    if (!_phoneFocus.hasFocus) _notifier?.patch(phoneNumber: _phoneCtl.text);
  }

  void _onDescBlur() {
    if (!_descFocus.hasFocus) {
      _notifier?.patch(physicalDescription: _descCtl.text);
    }
  }

  void _onAgeBlur() {
    if (!_ageFocus.hasFocus) {
      _notifier?.patch(age: int.tryParse(_ageCtl.text));
    }
  }

  void _onBloodBlur() {
    if (!_bloodFocus.hasFocus) _notifier?.patch(bloodType: _bloodCtl.text);
  }

  void _onAllergiesBlur() {
    if (!_allergiesFocus.hasFocus) {
      _notifier?.patch(allergies: _allergiesCtl.text);
    }
  }

  void _onMedsBlur() {
    if (!_medsFocus.hasFocus) _notifier?.patch(medications: _medsCtl.text);
  }

  void _onConditionsBlur() {
    if (!_conditionsFocus.hasFocus) {
      _notifier?.patch(medicalConditions: _conditionsCtl.text);
    }
  }

  void _onInstrBlur() {
    if (!_instrFocus.hasFocus) {
      _notifier?.patch(emergencyInstructions: _instrCtl.text);
    }
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
                focusNode: _nameFocus,
                decoration: InputDecoration(labelText: l10n.profileFieldName),
                onSubmitted: (String v) => notifier.patch(name: v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneCtl,
                focusNode: _phoneFocus,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: l10n.profileFieldPhone),
                onSubmitted: (String v) => notifier.patch(phoneNumber: v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _ageCtl,
                focusNode: _ageFocus,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.profileFieldAge),
                onSubmitted: (String v) => notifier.patch(age: int.tryParse(v)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descCtl,
                focusNode: _descFocus,
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
                focusNode: _bloodFocus,
                decoration: InputDecoration(
                  labelText: l10n.profileFieldBloodType,
                ),
                onSubmitted: (String v) => notifier.patch(bloodType: v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _allergiesCtl,
                focusNode: _allergiesFocus,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l10n.profileFieldAllergies,
                ),
                onSubmitted: (String v) => notifier.patch(allergies: v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _medsCtl,
                focusNode: _medsFocus,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l10n.profileFieldMedications,
                ),
                onSubmitted: (String v) => notifier.patch(medications: v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _conditionsCtl,
                focusNode: _conditionsFocus,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l10n.profileFieldMedicalConditions,
                ),
                onSubmitted: (String v) => notifier.patch(medicalConditions: v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _instrCtl,
                focusNode: _instrFocus,
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
