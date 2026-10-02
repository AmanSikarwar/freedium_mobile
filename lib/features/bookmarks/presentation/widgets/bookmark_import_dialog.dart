import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/features/bookmarks/application/bookmark_file_picker.dart';

class const BookmarkImportDialog({super.key}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<BookmarkImportDialog> createState() =>
      _BookmarkImportDialogState();
}

class _BookmarkImportDialogState extends ConsumerState<BookmarkImportDialog> {
  final _controller = TextEditingController();
  bool _reading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _chooseFile() async {
    setState(() {
      _reading = true;
      _error = null;
    });
    try {
      final backup = await ref.read(bookmarkFilePickerProvider)();
      if (mounted && backup != null) _controller.text = backup;
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not read this backup file');
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Import bookmarks'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: _reading ? null : _chooseFile,
            icon: const Icon(Icons.folder_open),
            label: Text(_reading ? 'Reading backup...' : 'Choose backup file'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 6,
            minLines: 3,
            decoration: const InputDecoration(
              hintText: 'Or paste a bookmarks backup (JSON)',
              border: OutlineInputBorder(),
            ),
          ),
          if (_error != null) Text(_error!),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _reading
            ? null
            : () => Navigator.pop(context, _controller.text),
        child: const Text('Import'),
      ),
    ],
  );
}
