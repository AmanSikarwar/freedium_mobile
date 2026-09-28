import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

/// Confirmation dialog for clearing an entire library list
/// (reading history, bookmarks).
///
/// Unifies the two previously duplicated `_confirmClear` dialogs. Always pops
/// with the dialog's own [dialogContext] — the bookmarks copy previously
/// popped with the outer context by mistake.
Future<void> showLibraryClearDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String failMessage,
  required Future<bool> Function() onClear,
  required VoidCallback onCleared,
}) {
  return showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            HapticFeedback.mediumImpact();
            final didClear = await onClear();
            if (!context.mounted || !dialogContext.mounted) return;

            if (didClear) {
              onCleared();
              Navigator.pop(dialogContext);
              return;
            }

            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(failMessage)));
          },
          child: const Text('Clear'),
        ),
      ],
    ),
  );
}
