import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/features/settings/application/settings_provider.dart';
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';

import 'add_mirror_dialog.dart';

void showAddMirrorDialog(BuildContext context, WidgetRef ref) {
  showDialog<void>(
    context: context,
    builder: (context) => AddMirrorDialog(
      onAdd: (mirror) {
        return ref.read(settingsProvider.notifier).addMirror(mirror);
      },
    ),
  );
}

void showEditMirrorDialog(
  BuildContext context,
  WidgetRef ref,
  FreediumMirror mirror,
) {
  showDialog<void>(
    context: context,
    builder: (context) => AddMirrorDialog(
      existingMirror: mirror,
      onAdd: (updatedMirror) {
        return ref
            .read(settingsProvider.notifier)
            .updateMirror(mirror, updatedMirror);
      },
    ),
  );
}

void confirmDeleteMirror(
  BuildContext context,
  WidgetRef ref,
  FreediumMirror mirror,
) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Mirror'),
      content: Text('Are you sure you want to delete "${mirror.name}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            HapticFeedback.mediumImpact();
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            final navigator = Navigator.of(context);
            final didRemove = await ref
                .read(settingsProvider.notifier)
                .removeMirror(mirror);
            if (!context.mounted) return;
            if (didRemove) {
              navigator.pop();
            } else {
              scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Text('Failed to remove mirror'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
