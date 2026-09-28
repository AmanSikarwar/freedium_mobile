import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/features/bookmarks/application/bookmark_io.dart';
import 'package:freedium_mobile/features/bookmarks/application/bookmarks_provider.dart';
import 'package:freedium_mobile/features/bookmarks/presentation/widgets/manage_folders_sheet.dart';
import 'package:freedium_mobile/features/bookmarks/presentation/widgets/move_to_folder_sheet.dart';
import 'package:freedium_mobile/features/history/application/history_provider.dart';
import 'package:freedium_mobile/features/history/domain/reading_history.dart';
import 'package:freedium_mobile/features/webview/application/webview_provider.dart';
import 'package:freedium_mobile/features/webview/presentation/webview_screen.dart';
import 'package:freedium_mobile/shared/utils/date_utils.dart' as du;
import 'package:freedium_mobile/shared/widgets/article_card.dart';
import 'package:freedium_mobile/shared/widgets/library_clear_dialog.dart';
import 'package:freedium_mobile/shared/widgets/library_list_view.dart';
import 'package:freedium_mobile/shared/widgets/library_search_header.dart';
import 'package:share_plus/share_plus.dart';

/// Sentinel filter value matching bookmarks without a folder.
const String unsortedFolderFilter = '';

class const BookmarksScreen({super.key}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState() extends ConsumerState<BookmarksScreen> {
  String _query = '';

  /// null = All, '' = Unsorted, otherwise the folder name.
  String? _folderFilter;
  final _searchController = TextEditingController();
  final _importController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _importController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    if (_query.isEmpty && _searchController.text.isEmpty) return;
    _searchController.clear();
    setState(() => _query = '');
  }

  void _clearFilters() {
    _clearSearch();
    setState(() => _folderFilter = null);
  }

  List<BookmarkedArticle> _filtered(List<BookmarkedArticle> bookmarks) {
    final query = _query.toLowerCase();
    return bookmarks.where((item) {
      final folder = _folderFilter;
      if (folder != null) {
        if (folder.isEmpty) {
          if (item.folder != null) return false;
        } else if (item.folder != folder) {
          return false;
        }
      }
      if (query.isEmpty) return true;
      return item.title.toLowerCase().contains(query) ||
          item.url.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _export() async {
    final bookmarks =
        ref.read(bookmarksProvider).value ?? const <BookmarkedArticle>[];
    final folders = ref.read(allBookmarkFoldersProvider);
    try {
      await ref.read(shareLauncherProvider)(
        ShareParams(
          subject: 'Freedium bookmarks backup',
          title: 'Share bookmarks backup',
          text: exportBookmarksJson(bookmarks, folders),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not share backup')));
    }
  }

  Future<void> _import() async {
    _importController.clear();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Import bookmarks'),
        content: TextField(
          controller: _importController,
          decoration: const InputDecoration(
            hintText: 'Paste a bookmarks backup (JSON)',
            border: OutlineInputBorder(),
          ),
          maxLines: 6,
          minLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    BookmarkImport parsed;
    try {
      parsed = parseBookmarksJson(_importController.text);
    } on FormatException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not a valid bookmarks backup')),
      );
      return;
    }
    final added = await ref
        .read(bookmarksProvider.notifier)
        .importBookmarks(parsed.bookmarks);
    if (!mounted) return;
    final skippedNote = parsed.skipped > 0
        ? ' (${parsed.skipped} skipped)'
        : '';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added > 0
              ? 'Imported $added bookmark${added == 1 ? '' : 's'}$skippedNote'
              : 'Nothing new to import$skippedNote',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookmarksAsync = ref.watch(bookmarksProvider);
    final bookmarks = bookmarksAsync.value ?? const <BookmarkedArticle>[];
    final folders = ref.watch(allBookmarkFoldersProvider);
    final historyByUrl = {
      for (final item
          in ref.watch(historyProvider).value ?? const <ReadingHistory>[])
        item.url: item,
    };
    final filtered = _filtered(bookmarks);
    final hasUnsorted = bookmarks.any((item) => item.folder == null);
    final counts = <String, int>{};
    var unsortedCount = 0;
    for (final item in bookmarks) {
      final folder = item.folder;
      if (folder == null) {
        unsortedCount++;
      } else {
        counts[folder] = (counts[folder] ?? 0) + 1;
      }
    }
    final showFilters = folders.isNotEmpty || _folderFilter != null;

    final grouped = du.buildGroupedList<BookmarkedArticle>(
      items: filtered,
      dateOf: (item) => item.savedAt,
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bookmarks'),
            if (bookmarks.isNotEmpty)
              Text(
                '${bookmarks.length} ${bookmarks.length == 1 ? 'article' : 'articles'}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        actions: [
          if (bookmarks.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.create_new_folder_outlined),
              tooltip: 'Manage folders',
              onPressed: () => showManageFoldersSheet(context),
            ),
            PopupMenuButton<String>(
              tooltip: 'More actions',
              onSelected: (value) {
                switch (value) {
                  case 'export':
                    _export();
                  case 'import':
                    _import();
                  case 'clear':
                    _confirmClear(context);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'export',
                  child: _OverflowMenuRow(
                    icon: Icons.upload_outlined,
                    label: 'Export bookmarks',
                  ),
                ),
                PopupMenuItem(
                  value: 'import',
                  child: _OverflowMenuRow(
                    icon: Icons.download_outlined,
                    label: 'Import bookmarks',
                  ),
                ),
                PopupMenuItem(
                  value: 'clear',
                  child: _OverflowMenuRow(
                    icon: Icons.delete_sweep_outlined,
                    label: 'Clear bookmarks',
                  ),
                ),
              ],
            ),
          ],
        ],
        bottom: bookmarks.isNotEmpty
            ? LibrarySearchHeader(
                controller: _searchController,
                hintText: 'Search bookmarks…',
                query: _query,
                onChanged: (v) => setState(() => _query = v),
                onClear: _clearSearch,
              )
            : null,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: libraryContentMaxWidth),
          child: bookmarksAsync.when(
            data: (_) => filtered.isEmpty
                ? LibraryEmptyState(
                    icon: _query.isNotEmpty || _folderFilter != null
                        ? Icons.search_off
                        : Icons.bookmark_border,
                    title: _query.isNotEmpty
                        ? 'No results for "$_query"'
                        : _folderFilter != null
                        ? 'No bookmarks here yet.'
                        : 'No saved articles yet.',
                    message: _query.isNotEmpty || _folderFilter != null
                        ? 'Try another title, URL, or folder.'
                        : 'Tap the bookmark icon while reading to save articles.',
                    actionLabel: _query.isNotEmpty || _folderFilter != null
                        ? 'Clear filters'
                        : null,
                    onAction: _query.isNotEmpty || _folderFilter != null
                        ? _clearFilters
                        : null,
                  )
                : Column(
                    children: [
                      if (showFilters)
                        _FolderFilterBar(
                          folders: folders,
                          counts: counts,
                          totalCount: bookmarks.length,
                          unsortedCount: unsortedCount,
                          hasUnsorted: hasUnsorted,
                          selected: _folderFilter,
                          onSelected: (folder) =>
                              setState(() => _folderFilter = folder),
                        ),
                      Expanded(
                        child: LibraryListView<BookmarkedArticle>(
                          grouped: grouped,
                          keyFor: (item) =>
                              '${item.url}_${item.savedAt.millisecondsSinceEpoch}',
                          titleFor: (item) => item.title,
                          subtitleFor: (item) {
                            final historyItem = historyByUrl[item.url];
                            final progress = historyItem?.progress ?? 0;
                            final relativeTime = du.relativeTime(item.savedAt);
                            final readingStatus =
                                historyItem?.isFinished ?? false
                                ? 'Finished'
                                : progress > 0
                                ? '${(progress * 100).round()}% read'
                                : null;
                            return readingStatus == null
                                ? relativeTime
                                : '$readingStatus • $relativeTime';
                          },
                          urlFor: (item) => item.url,
                          progressFor: (item) {
                            final progress =
                                historyByUrl[item.url]?.progress ?? 0;
                            return progress > 0 ? progress : null;
                          },
                          badgeFor: (item) => item.folder,
                          trailingFor: (item) => IconButton(
                            icon: Icon(
                              item.folder == null
                                  ? Icons.bookmark_border
                                  : Icons.bookmark,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            tooltip: 'Move to folder',
                            onPressed: () => showMoveToFolderSheet(
                              context,
                              ref,
                              url: item.url,
                            ),
                          ),
                          onRemove: (item) => ref
                              .read(bookmarksProvider.notifier)
                              .removeBookmark(item),
                          removeFailMessage: 'Failed to remove bookmark',
                          onTap: (item) => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => WebviewScreen(url: item.url),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => LibraryEmptyState(
              icon: Icons.error_outline,
              title: 'Something went wrong.',
              message: 'Could not load bookmarks.',
              actionLabel: 'Retry',
              onAction: () => ref.invalidate(bookmarksProvider),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showLibraryClearDialog(
      context: context,
      title: 'Clear Bookmarks',
      content: 'Are you sure you want to remove all saved articles?',
      failMessage: 'Failed to clear bookmarks',
      onClear: () => ref.read(bookmarksProvider.notifier).clearBookmarks(),
      onCleared: _clearFilters,
    );
  }
}

class const _OverflowMenuRow({required this.icon, required this.label})
    extends StatelessWidget {
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

class const _FolderFilterBar({
  required this.folders,
  required this.counts,
  required this.totalCount,
  required this.unsortedCount,
  required this.hasUnsorted,
  required this.selected,
  required this.onSelected,
}) extends StatelessWidget {
  final List<String> folders;
  final Map<String, int> counts;
  final int totalCount;
  final int unsortedCount;
  final bool hasUnsorted;

  /// null = All, '' = Unsorted, otherwise the folder name.
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
        child: Row(
          children: [
            _FilterChip(
              icon: Icons.bookmarks_outlined,
              label: 'All · $totalCount',
              selected: selected == null,
              onSelected: () => onSelected(null),
            ),
            if (hasUnsorted)
              _FilterChip(
                icon: Icons.folder_outlined,
                label: 'Unsorted · $unsortedCount',
                selected: selected == unsortedFolderFilter,
                onSelected: () => onSelected(unsortedFolderFilter),
              ),
            for (final folder in folders)
              _FilterChip(
                icon: Icons.folder,
                label: '$folder · ${counts[folder] ?? 0}',
                selected: selected == folder,
                onSelected: () => onSelected(folder),
              ),
          ],
        ),
      ),
    );
  }
}

class const _FilterChip({
  required this.icon,
  required this.label,
  required this.selected,
  required this.onSelected,
}) extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        showCheckmark: false,
      ),
    );
  }
}
