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
  final _bloodCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();
  List<String> _allergies = [];
  List<String> _medications = [];
  List<String> _conditions = [];
  bool _hydrated = false;

  void _hydrate(UserProfile? profile) {
    if (_hydrated) return;
    _hydrated = true;
    if (profile == null) return;
    _nameCtrl.text = profile.name ?? '';
    _ageCtrl.text = profile.age?.toString() ?? '';
    _bloodCtrl.text = profile.bloodType ?? '';
    _instructionsCtrl.text = profile.emergencyInstructions ?? '';
    _allergies = List.of(profile.allergies);
    _medications = List.of(profile.medications);
    _conditions = List.of(profile.medicalConditions);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _bloodCtrl.dispose();
    _instructionsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final profile = UserProfile(
      name: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
      age: int.tryParse(_ageCtrl.text),
      bloodType: _bloodCtrl.text.trim().isEmpty ? null : _bloodCtrl.text.trim(),
      allergies: List.unmodifiable(_allergies),
      medications: List.unmodifiable(_medications),
      medicalConditions: List.unmodifiable(_conditions),
      emergencyInstructions: _instructionsCtrl.text.trim().isEmpty
          ? null
          : _instructionsCtrl.text.trim(),
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
          TextField(
            controller: _ageCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l.profileFieldAge),
          ),
          TextField(
            controller: _bloodCtrl,
            decoration: InputDecoration(labelText: l.profileFieldBloodType),
          ),
          const SizedBox(height: 16),
          _ListEditor(
            label: l.profileFieldAllergies,
            items: _allergies,
            onChanged: (v) => setState(() => _allergies = v),
          ),
          _ListEditor(
            label: l.profileFieldMedications,
            items: _medications,
            onChanged: (v) => setState(() => _medications = v),
          ),
          _ListEditor(
            label: l.profileFieldConditions,
            items: _conditions,
            onChanged: (v) => setState(() => _conditions = v),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _instructionsCtrl,
            maxLines: 4,
            decoration: InputDecoration(labelText: l.profileFieldInstructions),
          ),
        ],
      ),
    );
  }
}

class _ListEditor extends StatefulWidget {
  const _ListEditor({
    required this.label,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final List<String> items;
  final ValueChanged<List<String>> onChanged;

  @override
  State<_ListEditor> createState() => _ListEditorState();
}

class _ListEditorState extends State<_ListEditor> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(widget.label, style: Theme.of(context).textTheme.titleMedium),
        for (var i = 0; i < widget.items.length; i++)
          ListTile(
            dense: true,
            title: Text(widget.items[i]),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                final copy = List<String>.of(widget.items)..removeAt(i);
                widget.onChanged(copy);
              },
            ),
          ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                decoration: InputDecoration(hintText: l.profileAddItem),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                final v = _ctrl.text.trim();
                if (v.isEmpty) return;
                widget.onChanged([...widget.items, v]);
                _ctrl.clear();
              },
            ),
          ],
        ),
      ],
    );
  }
}
