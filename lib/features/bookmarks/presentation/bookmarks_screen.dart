import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/features/bookmarks/application/bookmarks_provider.dart';
import 'package:freedium_mobile/features/webview/presentation/webview_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        actions: [
          if (bookmarks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear Bookmarks',
              onPressed: () => _confirmClear(context, ref),
            ),
        ],
      ),
      body: bookmarks.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No saved articles yet.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Tap the bookmark icon while reading to save articles.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                final item = bookmarks[index];
                return Dismissible(
                  key: ValueKey(
                    '${item.url}_${item.savedAt.millisecondsSinceEpoch}',
                  ),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    HapticFeedback.lightImpact();
                    ref.read(bookmarksProvider.notifier).removeBookmark(item);
                  },
                  child: ListTile(
                    leading: const Icon(Icons.bookmark),
                    title: Text(
                      item.title.isNotEmpty ? item.title : item.url,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(timeago.format(item.savedAt)),
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

  void _confirmClear(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
