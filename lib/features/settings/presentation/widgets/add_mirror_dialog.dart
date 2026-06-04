import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';

class AddMirrorDialog extends StatefulWidget {
  final FreediumMirror? existingMirror;
  final FutureOr<bool> Function(FreediumMirror mirror) onAdd;

  const AddMirrorDialog({super.key, this.existingMirror, required this.onAdd});

  @override
  State<AddMirrorDialog> createState() => _AddMirrorDialogState();
}

class _AddMirrorDialogState extends State<AddMirrorDialog> {
  late TextEditingController _nameController;
  late TextEditingController _urlController;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String? _submissionError;

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
    return AlertDialog(
      title: Text(isEditing ? 'Edit Mirror' : 'Add Custom Mirror'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: .min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'My Custom Mirror',
                prefixIcon: Icon(Icons.label),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL',
                hintText: 'https://freedium.example.com',
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: .url,
              validator: (value) {
                final url = value?.trim();
                if (url == null || url.isEmpty) {
                  return 'Please enter a URL';
                }
                final uri = Uri.tryParse(url);
                final scheme = uri?.scheme.toLowerCase();
                if (uri == null ||
                    !uri.hasScheme ||
                    uri.host.isEmpty ||
                    (scheme != 'http' && scheme != 'https')) {
                  return 'Please enter a valid URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Tip: Make sure the mirror uses the same API as freedium.cfd',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (_submissionError != null) ...[
              const SizedBox(height: 12),
              Text(
                _submissionError!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: Text(
            _isSubmitting ? 'Saving...' : (isEditing ? 'Save' : 'Add'),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    setState(() => _submissionError = null);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    HapticFeedback.mediumImpact();
    String url = _urlController.text.trim();
    while (url.length > 1 && url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    final mirror = FreediumMirror(
      name: _nameController.text.trim(),
      url: url,
      isCustom: true,
    );

    setState(() => _isSubmitting = true);
    final accepted = await Future<bool>.value(widget.onAdd(mirror));
    if (!mounted) return;

    if (accepted) {
      Navigator.pop(context);
    } else {
      setState(() {
        _isSubmitting = false;
        _submissionError = 'Mirror already exists or could not be saved.';
      });
    }
  }
}
