import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/features/settings/application/settings_provider.dart';
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';

import 'add_mirror_dialog.dart';

void showAddMirrorDialog(BuildContext context, WidgetRef ref) {
  M3EDialog.show<void>(
    context,
    dialog: AddMirrorDialog(
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
  M3EDialog.show<void>(
    context,
    dialog: AddMirrorDialog(
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
  M3EDialog.show<void>(
    context,
    autofocusFirst: false,
    dialog: M3EDialog(
      title: 'Delete Mirror',
      content: Text('Are you sure you want to delete "${mirror.name}"?'),
      actions: [
        M3EButton.text(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        M3EButton.filled(
          onPressed: () async {
            HapticFeedback.mediumImpact();
            final navigator = Navigator.of(context);
            final didRemove = await ref
                .read(settingsProvider.notifier)
                .removeMirror(mirror);
            if (!context.mounted) return;
            if (didRemove) {
              navigator.pop();
            } else {
              M3ESnackbar.show(
                context,
                message: 'Failed to remove mirror',
                duration: const Duration(seconds: 4),
              );
            }
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
