import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:safewayhome/l10n/app_localizations.dart';

import '../../core/theme/pride_widgets.dart';
import 'fake_call_controller.dart';

class FakeCallSettingsScreen extends ConsumerStatefulWidget {
  const FakeCallSettingsScreen({super.key});

  @override
  ConsumerState<FakeCallSettingsScreen> createState() =>
      _FakeCallSettingsScreenState();
}

class _FakeCallSettingsScreenState
    extends ConsumerState<FakeCallSettingsScreen> {
  late TextEditingController _nameController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final configAsync = ref.watch(fakeCallConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.fakeCallSettings),
        bottom: const PrideAppBarBottom(),
      ),
      body: configAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (config) {
          if (!_initialized) {
            _nameController.text = config.callerName;
            _initialized = true;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Caller name
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.callerName,
                  prefixIcon: const Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
                onChanged: (value) {
                  if (value.trim().isNotEmpty) {
                    ref
                        .read(fakeCallConfigProvider.notifier)
                        .updateConfig(callerName: value.trim());
                  }
                },
              ),
              const SizedBox(height: 24),

              // Caller photo
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text(l10n.callerPhoto),
                subtitle: Text(
                  config.photoPath != null
                      ? config.photoPath!.split('/').last
                      : l10n.noFileSelected,
                ),
                trailing: config.photoPath != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                FileImage(File(config.photoPath!)),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.close),
                            tooltip: l10n.removePhoto,
                            onPressed: () {
                              ref
                                  .read(fakeCallConfigProvider.notifier)
                                  .clearPhoto();
                            },
                          ),
                        ],
                      )
                    : null,
                onTap: () => _pickPhoto(context),
              ),
              const PrideDivider(),

              // Voice recording
              ListTile(
                leading: const Icon(Icons.mic),
                title: Text(l10n.voiceRecording),
                subtitle: Text(
                  config.voiceRecordingPath != null
                      ? config.voiceRecordingPath!.split('/').last
                      : l10n.noFileSelected,
                ),
                trailing: config.voiceRecordingPath != null
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: l10n.removePhoto,
                        onPressed: () {
                          ref
                              .read(fakeCallConfigProvider.notifier)
                              .clearVoiceRecording();
                        },
                      )
                    : null,
              ),
              const PrideDivider(),

              // Ring duration slider
              ListTile(
                leading: const Icon(Icons.timer),
                title: Text(l10n.ringDuration),
                subtitle: Slider(
                  value: config.ringDurationSeconds.toDouble(),
                  min: 5,
                  max: 60,
                  divisions: 11,
                  label: '${config.ringDurationSeconds}s',
                  onChanged: (value) {
                    ref
                        .read(fakeCallConfigProvider.notifier)
                        .updateConfig(ringDurationSeconds: value.round());
                  },
                ),
                trailing: Text(
                  '${config.ringDurationSeconds}s',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickPhoto(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (image == null) return;

    // Copy to app directory for persistence
    final appDir = await getApplicationDocumentsDirectory();
    final destPath = '${appDir.path}/fake_call_photo.jpg';
    await File(image.path).copy(destPath);

    ref
        .read(fakeCallConfigProvider.notifier)
        .updateConfig(photoPath: destPath);
  }
}
