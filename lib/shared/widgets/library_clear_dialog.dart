import 'package:material_3_expressive/material_3_expressive.dart';

import 'dart:async';

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
    dialog: _LibraryClearDialog(
      title: title,
      content: content,
      failMessage: failMessage,
      onClear: onClear,
      onCleared: onCleared,
    ),
  );
}

class const _LibraryClearDialog({
  required this.title,
  required this.content,
  required this.failMessage,
  required this.onClear,
  required this.onCleared,
}) extends StatefulWidget {
  final String title;
  final String content;
  final String failMessage;
  final Future<bool> Function() onClear;
  final VoidCallback onCleared;

  @override
  State<_LibraryClearDialog> createState() => _LibraryClearDialogState();
}

class _LibraryClearDialogState() extends State<_LibraryClearDialog> {
  bool _isClearing = false;

  @override
  Widget build(BuildContext context) {
    return M3EDialog(
      title: widget.title,
      content: Text(widget.content),
      actions: [
        M3EButton.text(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        M3EButton.filled(
          onPressed: () {
            unawaited(_clear());
          },
          child: const Text('Clear'),
        ),
      ],
    );
  }

  Future<void> _clear() async {
    if (_isClearing) return;
    _isClearing = true;
    try {
      HapticFeedback.mediumImpact();
      final didClear = await widget.onClear();

      // Only finish the flow while this dialog is still the active route.
      if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? false)) return;

      if (didClear) {
        widget.onCleared();
        Navigator.pop(context);
        return;
      }

      M3ESnackbar.show(
        context,
        message: widget.failMessage,
        duration: const Duration(seconds: 4),
      );
    } finally {
      _isClearing = false;
    }
  }
}
