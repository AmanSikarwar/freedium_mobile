import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

/// Confirmation dialog for clearing an entire library list
/// (reading history, bookmarks).
///
/// Unifies the two previously duplicated `_confirmClear` dialogs.
Future<void> showLibraryClearDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String failMessage,
  required Future<bool> Function() onClear,
  required VoidCallback onCleared,
}) {
  return M3EDialog.show<void>(
    context,
    autofocusFirst: false,
    dialog: M3EDialog(
      title: title,
      content: Text(content),
      actions: [
        M3EButton.text(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        M3EButton.filled(
          onPressed: () async {
            HapticFeedback.mediumImpact();
            final didClear = await onClear();
            if (!context.mounted) return;

            if (didClear) {
              onCleared();
              Navigator.pop(context);
              return;
            }

            M3ESnackbar.show(
              context,
              message: failMessage,
              duration: const Duration(seconds: 4),
            );
          },
          child: const Text('Clear'),
        ),
      ],
    ),
  );
}
