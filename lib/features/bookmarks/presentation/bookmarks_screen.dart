import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/features/bookmarks/application/bookmarks_provider.dart';
import 'package:freedium_mobile/features/history/application/history_provider.dart';
import 'package:freedium_mobile/features/history/domain/reading_history.dart';
import 'package:freedium_mobile/features/webview/presentation/webview_screen.dart';
import 'package:freedium_mobile/shared/utils/date_utils.dart' as du;
import 'package:freedium_mobile/shared/widgets/article_card.dart';
import 'package:freedium_mobile/shared/widgets/library_clear_dialog.dart';
import 'package:freedium_mobile/shared/widgets/library_list_view.dart';
import 'package:freedium_mobile/shared/widgets/library_search_header.dart';

class const BookmarksScreen({super.key}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState() extends ConsumerState<BookmarksScreen> {
  String _query = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    if (_query.isEmpty && _searchController.text.isEmpty) return;
    _searchController.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final bookmarksAsync = ref.watch(bookmarksProvider);
    final bookmarks = bookmarksAsync.value ?? const <BookmarkedArticle>[];
    final historyByUrl = {
      for (final item
          in ref.watch(historyProvider).value ?? const <ReadingHistory>[])
        item.url: item,
    };
    final filtered = _query.isEmpty
        ? bookmarks
        : bookmarks
              .where(
                (item) =>
                    item.title.toLowerCase().contains(_query.toLowerCase()) ||
                    item.url.toLowerCase().contains(_query.toLowerCase()),
              )
              .toList();

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
          if (bookmarks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear Bookmarks',
              onPressed: () => _confirmClear(context),
            ),
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
                    icon: _query.isNotEmpty
                        ? Icons.search_off
                        : Icons.bookmark_border,
                    title: _query.isNotEmpty
                        ? 'No results for "$_query"'
                        : 'No saved articles yet.',
                    message: _query.isNotEmpty ? 'Try another title or URL.' : 'Tap the bookmark icon while reading to save articles.',
                    actionLabel: _query.isNotEmpty ? 'Clear search' : null,
                    onAction: _query.isNotEmpty ? _clearSearch : null,
                  )
                : LibraryListView<BookmarkedArticle>(
                    grouped: grouped,
                    keyFor: (item) =>
                        '${item.url}_${item.savedAt.millisecondsSinceEpoch}',
                    titleFor: (item) => item.title,
                    subtitleFor: (item) {
                      final historyItem = historyByUrl[item.url];
                      final progress = historyItem?.progress ?? 0;
                      final relativeTime = du.relativeTime(item.savedAt);
                      final readingStatus = historyItem?.isFinished ?? false
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
                      final progress = historyByUrl[item.url]?.progress ?? 0;
                      return progress > 0 ? progress : null;
                    },
                    trailingFor: (_) => Icon(
                      Icons.bookmark,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onRemove: (item) => ref
                        .read(bookmarksProvider.notifier)
                        .removeBookmark(item),
                    removeFailMessage: 'Failed to remove bookmark',
                    onTap: (item) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WebviewScreen(url: item.url),
                      ),
                    ),
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
      onCleared: _clearSearch,
    );
  }
}
