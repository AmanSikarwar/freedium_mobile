import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:freedium_mobile/features/history/application/history_provider.dart';
import 'package:freedium_mobile/features/webview/presentation/webview_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear History',
              onPressed: () => _confirmClearHistory(context, ref),
            ),
        ],
      ),
      body: history.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: .min,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No reading history yet.'),
                ],
              ),
            )
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return Dismissible(
                  key: ValueKey(
                    '${item.url}_${item.timestamp.millisecondsSinceEpoch}',
                  ),
                  direction: .endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: .centerRight,
                    padding: const .only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    ref.read(historyProvider.notifier).removeHistory(item);
                    HapticFeedback.lightImpact();
                  },
                  child: ListTile(
                    title: Text(
                      item.title.isNotEmpty ? item.title : item.url,
                      maxLines: 2,
                      overflow: .ellipsis,
                    ),
                    subtitle: Padding(
                      padding: const .only(top: 4.0),
                      child: Text(timeago.format(item.timestamp)),
                    ),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebviewScreen(url: item.url),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  void _confirmClearHistory(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
