import 'package:material_3_expressive/material_3_expressive.dart';

import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/update_service.dart';
import 'package:freedium_mobile/core/utils/external_url_launcher.dart';
import 'package:freedium_mobile/features/home/presentation/widgets/changelog_bottom_sheet.dart';

class const UpdateCard({
  super.key,
  required this.updateInfo,
  required this.onDismissed,
}) extends ConsumerWidget {
  final UpdateInfo updateInfo;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: const Key('update_card'),
      onDismissed: (_) => onDismissed(),
      child: M3ECard(
        variant: M3ECardVariant.filled,
        padding: EdgeInsets.zero,
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Padding(
          padding: const .all(16),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.system_update,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          'Update Available',
                          style: TextStyle(
                            fontWeight: .bold,
                            fontSize: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'New version ${updateInfo.latestVersion}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: .end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  M3EButton.outlined(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      showChangelogBottomSheet(context, updateInfo);
                    },
                    icon: const Icon(Icons.article_outlined, size: 18),
                    label: const Text('View Changelog'),
                    decoration: M3EButtonDecoration(
                      foregroundColor: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                      side: WidgetStatePropertyAll(
                        BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  M3EButton.filled(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      unawaited(_launchUpdate(context, ref));
                    },
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Update'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUpdate(BuildContext context, WidgetRef ref) async {
    final launched = await ref.read(externalUrlLauncherProvider)(
      updateInfo.releaseUrl,
    );
    if (!context.mounted || launched) return;

    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Could not open link')));
  }
}
