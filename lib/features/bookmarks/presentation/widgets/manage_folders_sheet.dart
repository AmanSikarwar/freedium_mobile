import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/features/bookmarks/application/bookmarks_provider.dart';

/// Shows the manage-folders bottom sheet (create, rename, delete).
Future<void> showManageFoldersSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => const ManageFoldersSheet(),
  );
}

class const ManageFoldersSheet({super.key}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<ManageFoldersSheet> createState() => _ManageFoldersSheetState();
}

class _ManageFoldersSheetState() extends ConsumerState<ManageFoldersSheet> {
  final _createController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _createController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_saving) return;
    final name = _createController.text;
    if (normalizeBookmarkFolderName(name) == null) return;
    setState(() => _saving = true);
    final didCreate = await ref
        .read(bookmarkFoldersProvider.notifier)
        .createFolder(name);
    if (!mounted) return;
    setState(() => _saving = false);
    if (didCreate) {
      _createController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not create folder (duplicate or limit)'),
        ),
      );
    }
  }

  Future<void> _rename(String folder) async {
    final controller = TextEditingController(text: folder);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: maxBookmarkFolderNameLength,
          decoration: const InputDecoration(
            hintText: 'Folder name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newName == null || !mounted) return;
    final didRename = await ref
        .read(bookmarkFoldersProvider.notifier)
        .renameFolder(folder, newName);
    if (!mounted) return;
    if (!didRename) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not rename folder')));
    }
  }

  Future<void> _delete(String folder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete folder?'),
        content: Text(
          '"$folder" will be removed. Its articles stay bookmarked as Unsorted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final didDelete = await ref
        .read(bookmarkFoldersProvider.notifier)
        .deleteFolder(folder);
    if (!mounted) return;
    if (!didDelete) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not delete folder')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final foldersAsync = ref.watch(bookmarkFoldersProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Manage folders',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _createController,
                    decoration: const InputDecoration(
                      hintText: 'New folder name',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    maxLength: maxBookmarkFolderNameLength,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _create(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: _saving ? null : _create,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: foldersAsync.when(
                data: (folders) => folders.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'No folders yet. Create one above.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView(
                        shrinkWrap: true,
                        children: [
                          for (final folder in folders)
                            ListTile(
                              leading: const Icon(Icons.folder_outlined),
                              title: Text(folder),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    tooltip: 'Rename',
                                    onPressed: () => _rename(folder),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    tooltip: 'Delete',
                                    onPressed: () => _delete(folder),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, _) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Could not load folders.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
