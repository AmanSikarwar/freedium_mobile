import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:freedium_mobile/features/bookmarks/domain/bookmark_folder.dart';

/// Provides a rename dialog whose text controller follows the dialog lifecycle.
class const RenameBookmarkFolderDialog({required this.folder, super.key})
    extends StatefulWidget {
  final String folder;

  @override
  State<RenameBookmarkFolderDialog> createState() =>
      _RenameBookmarkFolderDialogState();
}

class _RenameBookmarkFolderDialogState()
    extends State<RenameBookmarkFolderDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.folder);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename folder'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: maxBookmarkFolderNameLength,
        decoration: const InputDecoration(
          hintText: 'Folder name',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        M3EButton.text(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        M3EButton.filled(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Rename'),
        ),
      ],
    );
  }
}
