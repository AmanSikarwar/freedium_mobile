import 'package:flutter/material.dart';
import 'package:freedium_mobile/core/services/update_service.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateCard extends StatelessWidget {
  const UpdateCard({
    super.key,
    required this.updateInfo,
    required this.onDismissed,
  });

  final UpdateInfo updateInfo;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: const Key('update_card'),
      onDismissed: (_) => onDismissed(),
      child: Card(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update Available: ${updateInfo.latestVersion}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                updateInfo.releaseNotes,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onDismissed,
                    child: const Text('Later'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed:
                        () => launchUrl(Uri.parse(updateInfo.releaseUrl)),
                    child: const Text('Update'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
