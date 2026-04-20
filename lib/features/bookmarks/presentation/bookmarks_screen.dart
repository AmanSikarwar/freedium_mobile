import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/features/bookmarks/application/bookmarks_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final bookmarks = ref.watch(bookmarksProvider);

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
        title: const Text('Bookmarks'),
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
                preferredSize: const Size.fromHeight(56),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: SearchBar(
                    controller: _searchController,
                    hintText: 'Search bookmarks…',
                    leading: const Icon(Icons.search),
                    trailing: [
                      if (_query.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
                    ],
                    onChanged: (v) => setState(() => _query = v),
                    elevation: const WidgetStatePropertyAll(0),
                  ),
                ),
              )
            : null,
      ),
      body: filtered.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _query.isNotEmpty
                        ? Icons.search_off
                        : Icons.bookmark_border,
                    size: 64,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _query.isNotEmpty
                        ? 'No results for "$_query"'
                        : 'No saved articles yet.',
                  ),
                  if (_query.isEmpty) ...[
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Tap the bookmark icon while reading to save articles.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            )
          : ListView.builder(
              itemCount: grouped.length,
              itemBuilder: (context, index) {
                final entry = grouped[index];

                if (entry is String) {
                  return DateGroupHeader(label: entry);
                }

                final item = entry as BookmarkedArticle;
                return Dismissible(
                  key: ValueKey(
                    '${item.url}_${item.savedAt.millisecondsSinceEpoch}',
                  ),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Theme.of(context).colorScheme.errorContainer,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                  onDismissed: (_) {
                    HapticFeedback.lightImpact();
                    ref.read(bookmarksProvider.notifier).removeBookmark(item);
                  },
                  child: ArticleCard(
                    title: item.title,
                    subtitle: du.relativeTime(item.savedAt),
                    url: item.url,
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
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.read(bookmarksProvider.notifier).clearBookmarks();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
