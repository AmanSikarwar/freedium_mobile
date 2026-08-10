import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/features/history/application/history_provider.dart';
import 'package:freedium_mobile/features/history/domain/reading_history.dart';
import 'package:freedium_mobile/features/webview/presentation/webview_screen.dart';
import 'package:freedium_mobile/shared/utils/date_utils.dart' as du;
import 'package:freedium_mobile/shared/widgets/article_card.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
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
    final history = ref.watch(historyProvider);
    final lowercaseQuery = _query.toLowerCase();
    const searchBarHeight = 56.0;
    const searchBarBottomPadding = 8.0;
    const searchAreaHeight = searchBarHeight + searchBarBottomPadding;

    final filtered = _query.isEmpty
        ? List<ReadingHistory>.from(history)
        : history
              .where(
                (item) =>
                    item.title.toLowerCase().contains(lowercaseQuery) ||
                    item.url.toLowerCase().contains(lowercaseQuery),
              )
              .toList();
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final grouped = du.buildGroupedList<ReadingHistory>(
      items: filtered,
      dateOf: (item) => item.timestamp,
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('History'),
            if (history.isNotEmpty)
              Text(
                '${history.length} ${history.length == 1 ? 'article' : 'articles'}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear History',
              onPressed: () => _confirmClear(context),
            ),
        ],
        bottom: history.isNotEmpty
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
                        hintText: 'Search history…',
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
                  icon: _query.isNotEmpty ? Icons.search_off : Icons.history,
                  title: _query.isNotEmpty
                      ? 'No results for "$_query"'
                      : 'No reading history yet.',
                  message: _query.isNotEmpty
                      ? 'Try another title or URL.'
                      : 'Articles you open will appear here with their reading progress.',
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

                    final item = entry as ReadingHistory;
                    final relativeTime = du.relativeTime(item.timestamp);
                    final readingStatus = item.isFinished
                        ? 'Finished'
                        : item.progress > 0
                        ? '${(item.progress * 100).round()}% read'
                        : null;
                    return Dismissible(
                      key: ValueKey(
                        '${item.url}_${item.timestamp.millisecondsSinceEpoch}',
                      ),
                      direction: DismissDirection.endToStart,
                      background: const ArticleDismissBackground(),
                      confirmDismiss: (_) async {
                        HapticFeedback.lightImpact();
                        final didRemove = await ref
                            .read(historyProvider.notifier)
                            .removeHistory(item);
                        if (!context.mounted) return false;

                        if (!didRemove) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to remove history entry'),
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
                        progress: item.progress > 0 ? item.progress : null,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WebviewScreen(url: item.url),
                          ),
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
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to clear all reading history?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              HapticFeedback.mediumImpact();
              final didClear = await ref
                  .read(historyProvider.notifier)
                  .clearHistory();
              if (!context.mounted || !dialogContext.mounted) return;

              if (didClear) {
                _clearSearch();
                Navigator.pop(dialogContext);
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to clear history')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
