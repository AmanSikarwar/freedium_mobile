import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/features/bookmarks/application/bookmarks_provider.dart';

/// Shows the move-to-folder bottom sheet for the bookmarked article [url].
Future<void> showMoveToFolderSheet(
  BuildContext context,
  WidgetRef ref, {
  required String url,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => MoveToFolderSheet(url: url),
  );
}

class const MoveToFolderSheet({super.key, required this.url})
    extends ConsumerStatefulWidget {
  final String url;

  @override
  ConsumerState<MoveToFolderSheet> createState() => _MoveToFolderSheetState();
}

class _MoveToFolderSheetState() extends ConsumerState<MoveToFolderSheet> {
  final _newFolderController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _newFolderController.dispose();
    super.dispose();
  }

  String? _currentFolder(List<BookmarkedArticle> bookmarks) {
    for (final b in bookmarks) {
      if (b.url == widget.url) return b.folder;
    }
    return null;
  }

  Future<void> _move(String? folder) async {
    if (_saving) return;
    setState(() => _saving = true);
    final didMove = await ref
        .read(bookmarksProvider.notifier)
        .setArticleFolder(widget.url, folder);
    if (!mounted) return;
    Navigator.pop(context);
    if (!didMove) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to move bookmark')));
    }
  }

  Future<void> _createAndMove() async {
    final name = _newFolderController.text;
    if (normalizeBookmarkFolderName(name) == null) return;
    if (_saving) return;
    setState(() => _saving = true);
    final folders = ref.read(bookmarkFoldersProvider.notifier);
    final didCreate = await folders.createFolder(name);
    if (!didCreate && mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not create folder')));
      return;
    }
    final normalized = normalizeBookmarkFolderName(name);
    final didMove = await ref
        .read(bookmarksProvider.notifier)
        .setArticleFolder(widget.url, normalized);
    if (!mounted) return;
    Navigator.pop(context);
    if (!didMove) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to move bookmark')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final folders = ref.watch(allBookmarkFoldersProvider);
    final bookmarks =
        ref.watch(bookmarksProvider).value ?? const <BookmarkedArticle>[];
    final current = _currentFolder(bookmarks);
    final counts = <String, int>{};
    var unsortedCount = 0;
    for (final article in bookmarks) {
      final folder = article.folder;
      if (folder == null) {
        unsortedCount++;
      } else {
        counts[folder] = (counts[folder] ?? 0) + 1;
      }
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Move to folder',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  _FolderOption(
                    label: 'Unsorted',
                    subtitle: '$unsortedCount here',
                    icon: Icons.folder_outlined,
                    selected: current == null,
                    onTap: () => _move(null),
                  ),
                  for (final folder in folders)
                    _FolderOption(
                      label: folder,
                      subtitle: '${counts[folder] ?? 0} here',
                      icon: Icons.folder,
                      selected: current == folder,
                      onTap: () => _move(folder),
                    ),
                ],
              ),
            ),
            const Divider(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _newFolderController,
                    decoration: const InputDecoration(
                      hintText: 'New folder name',
                      prefixIcon: Icon(Icons.create_new_folder_outlined),
                      border: OutlineInputBorder(),
                      isDense: true,
                      counterText: '',
                    ),
                    maxLength: maxBookmarkFolderNameLength,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _createAndMove(),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: ValueListenableBuilder(
                    valueListenable: _newFolderController,
                    builder: (context, value, _) {
                      final hasText = value.text.trim().isNotEmpty;
                      return FilledButton.tonalIcon(
                        onPressed: _saving || !hasText ? null : _createAndMove,
                        icon: const Icon(Icons.create_new_folder_outlined),
                        label: const Text('Create'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class const _FolderOption({
  required this.label,
  required this.subtitle,
  required this.icon,
  required this.selected,
  required this.onTap,
}) extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: selected
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
      title: Text(label),
      subtitle: Text(subtitle),
      trailing: selected
          ? Icon(Icons.check, color: theme.colorScheme.primary)
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
