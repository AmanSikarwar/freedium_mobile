import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';

class AddMirrorDialog extends StatefulWidget {
  final FreediumMirror? existingMirror;
  final void Function(FreediumMirror mirror) onAdd;

  const AddMirrorDialog({super.key, this.existingMirror, required this.onAdd});

  @override
  State<AddMirrorDialog> createState() => _AddMirrorDialogState();
}

class _AddMirrorDialogState extends State<AddMirrorDialog> {
  late TextEditingController _nameController;
  late TextEditingController _urlController;
  final _formKey = GlobalKey<FormState>();

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
                if (value == null || value.isEmpty) {
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
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a URL';
                }
                final uri = Uri.tryParse(value);
                if (uri == null ||
                    !uri.hasScheme ||
                    uri.host.isEmpty ||
                    (uri.scheme != 'http' && uri.scheme != 'https')) {
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      String url = _urlController.text.trim();
      if (url.endsWith('/')) {
        url = url.substring(0, url.length - 1);
      }

      final mirror = FreediumMirror(
        name: _nameController.text.trim(),
        url: url,
        isCustom: true,
      );

      widget.onAdd(mirror);
      Navigator.pop(context);
    }
  }
}
