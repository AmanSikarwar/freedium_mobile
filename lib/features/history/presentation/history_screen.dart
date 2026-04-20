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

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);

    final filtered = _query.isEmpty
        ? history
        : history
              .where(
                (item) =>
                    item.title.toLowerCase().contains(_query.toLowerCase()) ||
                    item.url.toLowerCase().contains(_query.toLowerCase()),
              )
              .toList();

    final grouped = du.buildGroupedList<ReadingHistory>(
      items: filtered,
      dateOf: (item) => item.timestamp,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
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
                preferredSize: const Size.fromHeight(56),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: SearchBar(
                    controller: _searchController,
                    hintText: 'Search history…',
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
                    _query.isNotEmpty ? Icons.search_off : Icons.history,
                    size: 64,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _query.isNotEmpty
                        ? 'No results for "$_query"'
                        : 'No reading history yet.',
                  ),
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

                final item = entry as ReadingHistory;
                return Dismissible(
                  key: ValueKey(
                    '${item.url}_${item.timestamp.millisecondsSinceEpoch}',
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
                    ref.read(historyProvider.notifier).removeHistory(item);
                  },
                  child: ArticleCard(
                    title: item.title,
                    subtitle: du.relativeTime(item.timestamp),
                    url: item.url,
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
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to clear all reading history?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.read(historyProvider.notifier).clearHistory();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
