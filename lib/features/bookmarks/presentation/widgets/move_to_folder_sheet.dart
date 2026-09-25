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
    final folders = ref.watch(allBookmarkFoldersProvider);
    final bookmarks =
        ref.watch(bookmarksProvider).value ?? const <BookmarkedArticle>[];
    final current = _currentFolder(bookmarks);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Move to folder',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  _FolderOption(
                    label: 'Unsorted',
                    icon: Icons.folder_outlined,
                    selected: current == null,
                    onTap: () => _move(null),
                  ),
                  for (final folder in folders)
                    _FolderOption(
                      label: folder,
                      icon: Icons.folder,
                      selected: current == folder,
                      onTap: () => _move(folder),
                    ),
                ],
              ),
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newFolderController,
                    decoration: const InputDecoration(
                      hintText: 'New folder name',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    maxLength: maxBookmarkFolderNameLength,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _createAndMove(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: _saving ? null : _createAndMove,
                  icon: const Icon(Icons.create_new_folder_outlined),
                  label: const Text('Create'),
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
  required this.icon,
  required this.selected,
  required this.onTap,
}) extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: selected ? const Icon(Icons.check) : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
