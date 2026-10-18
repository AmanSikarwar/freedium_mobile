import 'package:material_3_expressive/material_3_expressive.dart';

import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:freedium_mobile/core/utils/url.dart'
    show normalizeMirrorUrl, trimTrailingSlash;
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';

class const AddMirrorDialog({
  super.key,
  this.existingMirror,
  required this.onAdd,
}) extends StatefulWidget {
  final FreediumMirror? existingMirror;
  final FutureOr<bool> Function(FreediumMirror mirror) onAdd;

  @override
  State<AddMirrorDialog> createState() => _AddMirrorDialogState();
}

class _AddMirrorDialogState() extends State<AddMirrorDialog> {
  late TextEditingController _nameController;
  late TextEditingController _urlController;
  bool _isSubmitting = false;
  String? _submissionError;
  String? _nameError;
  String? _urlError;

  bool get isEditing => widget.existingMirror != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingMirror?.name ?? '',
    );
    _urlController = TextEditingController(
      text: widget.existingMirror?.url ?? 'https://',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return M3EDialog(
      title: isEditing ? 'Edit Mirror' : 'Add Custom Mirror',
      content: Column(
        mainAxisSize: .min,
        children: [
          M3ETextField(
            controller: _nameController,
            label: 'Name',
            placeholder: 'My Custom Mirror',
            leading: const Icon(Icons.label),
            errorText: _nameError,
          ),
          const SizedBox(height: 16),
          M3ETextField(
            controller: _urlController,
            label: 'URL',
            placeholder: 'https://freedium.example.com',
            leading: const Icon(Icons.link),
            keyboardType: .url,
            errorText: _urlError,
          ),
          const SizedBox(height: 16),
          Text(
            'Tip: Make sure the mirror uses the same API as freedium-mirror.cfd',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (_submissionError != null) ...[
            const SizedBox(height: 12),
            Text(
              _submissionError!,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        M3EButton.text(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        M3EButton.filled(
          onPressed: _isSubmitting ? null : _submit,
          child: Text(
            _isSubmitting ? 'Saving...' : (isEditing ? 'Save' : 'Add'),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    setState(() {
      _submissionError = null;
      _nameError = _nameController.text.trim().isEmpty
          ? 'Please enter a name'
          : null;
      final rawUrl = _urlController.text.trim();
      _urlError = rawUrl.isEmpty
          ? 'Please enter a URL'
          : normalizeMirrorUrl(rawUrl) == null
          ? 'Please enter a valid HTTPS mirror URL'
          : null;
    });
    if (_nameError != null || _urlError != null) {
      return;
    }

    HapticFeedback.mediumImpact();
    final rawUrl = _urlController.text.trim();
    // Validation already guarantees a normalizable URL.
    final url = normalizeMirrorUrl(rawUrl) ?? trimTrailingSlash(rawUrl);

    final mirror = FreediumMirror(
      name: _nameController.text.trim(),
      url: url,
      isCustom: true,
    );

    setState(() => _isSubmitting = true);
    final bool accepted;
    try {
      accepted = await Future<bool>.value(widget.onAdd(mirror));
    } catch (_) {
      if (!mounted) return;
      _showSubmissionError();
      return;
    }
    if (!mounted) return;

    if (accepted) {
      Navigator.pop(context);
    } else {
      _showSubmissionError();
    }
  }

  void _showSubmissionError() {
    setState(() {
      _isSubmitting = false;
      _submissionError = 'Mirror already exists or could not be saved.';
    });
  }
}
