import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/features/history/application/history_provider.dart';
import 'package:freedium_mobile/features/history/domain/reading_history.dart';
import 'package:freedium_mobile/features/webview/presentation/webview_screen.dart';
import 'package:freedium_mobile/shared/utils/date_utils.dart' as du;
import 'package:freedium_mobile/shared/widgets/article_card.dart';
import 'package:freedium_mobile/shared/widgets/library_clear_dialog.dart';
import 'package:freedium_mobile/shared/widgets/library_list_view.dart';
import 'package:freedium_mobile/shared/widgets/library_search_header.dart';

class const HistoryScreen({super.key}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState() extends ConsumerState<HistoryScreen> {
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
    final historyAsync = ref.watch(historyProvider);
    final history = historyAsync.value ?? const <ReadingHistory>[];
    final lowercaseQuery = _query.toLowerCase();

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
            ? LibrarySearchHeader(
                controller: _searchController,
                hintText: 'Search history…',
                query: _query,
                onChanged: (v) => setState(() => _query = v),
                onClear: _clearSearch,
              )
            : null,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: libraryContentMaxWidth),
          child: historyAsync.when(
            data: (_) => filtered.isEmpty
                ? LibraryEmptyState(
                    icon: _query.isNotEmpty ? Icons.search_off : Icons.history,
                    title: _query.isNotEmpty
                        ? 'No results for "$_query"'
                        : 'No reading history yet.',
                    message: _query.isNotEmpty ? 'Try another title or URL.' : 'Articles you open will appear here with their reading progress.',
                    actionLabel: _query.isNotEmpty ? 'Clear search' : null,
                    onAction: _query.isNotEmpty ? _clearSearch : null,
                  )
                : LibraryListView<ReadingHistory>(
                    grouped: grouped,
                    keyFor: (item) =>
                        '${item.url}_${item.timestamp.millisecondsSinceEpoch}',
                    titleFor: (item) => item.title,
                    subtitleFor: (item) {
                      final relativeTime = du.relativeTime(item.timestamp);
                      final readingStatus = item.isFinished
                          ? 'Finished'
                          : item.progress > 0
                          ? '${(item.progress * 100).round()}% read'
                          : null;
                      return readingStatus == null
                          ? relativeTime
                          : '$readingStatus • $relativeTime';
                    },
                    urlFor: (item) => item.url,
                    progressFor: (item) =>
                        item.progress > 0 ? item.progress : null,
                    trailingFor: (_) => null,
                    onRemove: (item) =>
                        ref.read(historyProvider.notifier).removeHistory(item),
                    removeFailMessage: 'Failed to remove history entry',
                    onTap: (item) => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => WebviewScreen(url: item.url),
                      ),
                    ),
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => LibraryEmptyState(
              icon: Icons.error_outline,
              title: 'Something went wrong.',
              message: 'Could not load reading history.',
              actionLabel: 'Retry',
              onAction: () => ref.invalidate(historyProvider),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showLibraryClearDialog(
      context: context,
      title: 'Clear History',
      content: 'Are you sure you want to clear all reading history?',
      failMessage: 'Failed to clear history',
      onClear: () => ref.read(historyProvider.notifier).clearHistory(),
      onCleared: _clearSearch,
    );
  }
}
