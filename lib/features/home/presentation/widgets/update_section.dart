import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/update_service.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateSection extends ConsumerStatefulWidget {
  const UpdateSection({super.key});

  @override
  ConsumerState<UpdateSection> createState() => _UpdateSectionState();
}

class _UpdateSectionState extends ConsumerState<UpdateSection> {
  bool _isLoading = false;
  UpdateInfo? _updateInfo;
  bool _noUpdateAvailable = false;

  Future<void> _checkForUpdate() async {
    setState(() {
      _isLoading = true;
      _noUpdateAvailable = false;
    });

    final updateService = ref.read(updateServiceProvider);
    final updateInfo = await updateService.checkForUpdate();

    if (mounted) {
      setState(() {
        _isLoading = false;
        _updateInfo = updateInfo;
        if (updateInfo == null) {
          _noUpdateAvailable = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          if (_isLoading)
            const CircularProgressIndicator()
          else if (_noUpdateAvailable)
            const Text('You are using the latest version!')
          else if (_updateInfo != null)
            Column(
              children: [
                Text('Latest Version: ${_updateInfo!.latestVersion}'),
                TextButton(
                  onPressed: () =>
                      launchUrl(Uri.parse(_updateInfo!.releaseUrl)),
                  child: const Text('View Release Notes'),
                ),
              ],
            )
          else
            OutlinedButton.icon(
              onPressed: _checkForUpdate,
              icon: const Icon(Icons.update),
              label: const Text('Check for Updates'),
            ),
        ],
      ),
    );
  }
}
