import 'package:freedium_mobile/shared/widgets/expressive_icon_button.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/features/bookmarks/application/bookmarks_provider.dart';
import 'package:freedium_mobile/features/bookmarks/presentation/widgets/rename_bookmark_folder_dialog.dart';

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
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => RenameBookmarkFolderDialog(folder: folder),
    );
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
          M3EButton.text(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          M3EButton.filled(
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
    final theme = Theme.of(context);
    final foldersAsync = ref.watch(bookmarkFoldersProvider);
    final folders = ref.watch(allBookmarkFoldersProvider);
    final bookmarks =
        ref.watch(bookmarksProvider).value ?? const <BookmarkedArticle>[];
    final counts = <String, int>{};
    for (final article in bookmarks) {
      final folder = article.folder;
      if (folder != null) {
        counts[folder.toLowerCase()] = (counts[folder.toLowerCase()] ?? 0) + 1;
      }
    }

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
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Manage folders',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${foldersAsync.value?.length ?? 0}/$maxBookmarkFolders '
                  'saved · ${folders.length} total',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _createController,
                    decoration: const InputDecoration(
                      hintText: 'New folder name',
                      prefixIcon: Icon(Icons.create_new_folder_outlined),
                      border: OutlineInputBorder(),
                      isDense: true,
                      counterText: '',
                    ),
                    maxLength: maxBookmarkFolderNameLength,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _create(),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: ValueListenableBuilder(
                    valueListenable: _createController,
                    builder: (context, value, _) {
                      final hasText = value.text.trim().isNotEmpty;
                      return M3EButton.tonal(
                        onPressed: _saving || !hasText ? null : _create,
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: foldersAsync.when(
                data: (_) => folders.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.create_new_folder_outlined,
                              size: 40,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No folders yet. Create one above to organize your bookmarks.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: folders.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final folder = folders[index];
                          final count = counts[folder.toLowerCase()] ?? 0;
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.folder,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            title: Text(folder),
                            subtitle: Text(
                              count == 0
                                  ? 'Empty'
                                  : '$count article${count == 1 ? '' : 's'}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ExpressiveIconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  tooltip: 'Rename',
                                  onPressed: () => _rename(folder),
                                ),
                                ExpressiveIconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: theme.colorScheme.error,
                                  ),
                                  tooltip: 'Delete',
                                  onPressed: () => _delete(folder),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: M3EProgressIndicator.circularWavy(),
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
