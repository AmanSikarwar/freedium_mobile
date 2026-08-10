import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/features/bookmarks/application/bookmarks_provider.dart';
import 'package:freedium_mobile/features/history/application/history_provider.dart';
import 'package:freedium_mobile/features/webview/presentation/webview_screen.dart';
import 'package:freedium_mobile/shared/utils/date_utils.dart' as du;
import 'package:freedium_mobile/shared/widgets/article_card.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
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
    final bookmarks = ref.watch(bookmarksProvider);
    final historyByUrl = {
      for (final item in ref.watch(historyProvider)) item.url: item,
    };
    const searchBarHeight = 56.0;
    const searchBarBottomPadding = 8.0;
    const searchAreaHeight = searchBarHeight + searchBarBottomPadding;

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
            ? PreferredSize(
                preferredSize: Size.fromHeight(searchAreaHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: libraryContentMaxWidth,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        12,
                        0,
                        12,
                        searchBarBottomPadding,
                      ),
                      child: SearchBar(
                        controller: _searchController,
                        hintText: 'Search bookmarks…',
                        leading: const Icon(Icons.search),
                        trailing: [
                          if (_query.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.close),
                              tooltip: 'Clear search',
                              onPressed: _clearSearch,
                            ),
                        ],
                        onChanged: (v) => setState(() => _query = v),
                        elevation: const WidgetStatePropertyAll(0),
                        side: WidgetStatePropertyAll(
                          BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: libraryContentMaxWidth),
          child: filtered.isEmpty
              ? LibraryEmptyState(
                  icon: _query.isNotEmpty
                      ? Icons.search_off
                      : Icons.bookmark_border,
                  title: _query.isNotEmpty
                      ? 'No results for "$_query"'
                      : 'No saved articles yet.',
                  message: _query.isNotEmpty
                      ? 'Try another title or URL.'
                      : 'Tap the bookmark icon while reading to save articles.',
                  actionLabel: _query.isNotEmpty ? 'Clear search' : null,
                  onAction: _query.isNotEmpty ? _clearSearch : null,
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 24),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final entry = grouped[index];

                    if (entry is String) {
                      return DateGroupHeader(label: entry);
                    }

                    final item = entry as BookmarkedArticle;
                    final historyItem = historyByUrl[item.url];
                    final progress = historyItem?.progress ?? 0;
                    final relativeTime = du.relativeTime(item.savedAt);
                    final readingStatus = historyItem?.isFinished ?? false
                        ? 'Finished'
                        : progress > 0
                        ? '${(progress * 100).round()}% read'
                        : null;
                    return Dismissible(
                      key: ValueKey(
                        '${item.url}_${item.savedAt.millisecondsSinceEpoch}',
                      ),
                      direction: DismissDirection.endToStart,
                      background: const ArticleDismissBackground(),
                      confirmDismiss: (_) async {
                        HapticFeedback.lightImpact();
                        final didRemove = await ref
                            .read(bookmarksProvider.notifier)
                            .removeBookmark(item);
                        if (!context.mounted) return false;

                        if (!didRemove) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to remove bookmark'),
                            ),
                          );
                        }

                        return didRemove;
                      },
                      child: ArticleCard(
                        title: item.title,
                        subtitle: readingStatus == null
                            ? relativeTime
                            : '$readingStatus • $relativeTime',
                        url: item.url,
                        progress: progress > 0 ? progress : null,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WebviewScreen(url: item.url),
                          ),
                        ),
                        trailingIcon: Icon(
                          Icons.bookmark,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Bookmarks'),
        content: const Text(
          'Are you sure you want to remove all saved articles?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              HapticFeedback.mediumImpact();
              final didClear = await ref
                  .read(bookmarksProvider.notifier)
                  .clearBookmarks();
              if (!context.mounted) return;

              if (didClear) {
                _clearSearch();
                Navigator.pop(context);
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to clear bookmarks')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
