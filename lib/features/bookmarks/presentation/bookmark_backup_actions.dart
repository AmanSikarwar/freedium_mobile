import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/features/bookmarks/application/bookmark_io.dart';
import 'package:freedium_mobile/features/bookmarks/application/bookmarks_provider.dart';
import 'package:freedium_mobile/features/bookmarks/presentation/widgets/bookmark_import_dialog.dart';
import 'package:freedium_mobile/features/webview/application/webview_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> exportBookmarkBackup(BuildContext context, WidgetRef ref) async {
  try {
    final bookmarks = await ref.read(bookmarksProvider.future);
    final folders = ref.read(allBookmarkFoldersProvider);
    final result = await ref.read(shareLauncherProvider)(
      ShareParams(
        subject: 'Freedium bookmarks backup',
        title: 'Share bookmarks backup',
        files: [
          XFile.fromData(
            utf8.encode(exportBookmarksJson(bookmarks, folders)),
            mimeType: 'application/json',
          ),
        ],
        fileNameOverrides: ['freedium-bookmarks.json'],
      ),
    );
    if (result.status == ShareResultStatus.unavailable) {
      throw StateError('Sharing unavailable');
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not share backup')));
    }
  }
}

Future<void> importBookmarkBackup(BuildContext context, WidgetRef ref) async {
  final raw = await showDialog<String>(
    context: context,
    builder: (_) => const BookmarkImportDialog(),
  );
  if (raw == null || !context.mounted) return;
  final BookmarkImport parsed;
  try {
    parsed = parseBookmarksJson(raw);
  } on FormatException {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Not a valid bookmarks backup')),
    );
    return;
  }
  final current = await ref.read(bookmarksProvider.future);
  if (!context.mounted) return;
  final known = {for (final article in current) article.url};
  final fresh = {for (final article in parsed.bookmarks) article.url}
      .difference(known);
  final duplicateCount = parsed.bookmarks.length - fresh.length;
  final available = (Bookmarks.maxBookmarks - current.length).clamp(
    0,
    Bookmarks.maxBookmarks,
  );
  final retained = fresh.length.clamp(0, available);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Restore bookmarks?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$retained new articles'),
          Text('$duplicateCount duplicates'),
          Text('${parsed.skipped} invalid entries skipped'),
          if (fresh.length > retained)
            Text('${fresh.length - retained} over the bookmark limit'),
          Text('${parsed.folders.length} folders in backup'),
          const SizedBox(height: 8),
          const Text('Your existing bookmarks will be kept.'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Restore'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  final bookmarks = ref.read(bookmarksProvider.notifier);
  final folders = ref.read(bookmarkFoldersProvider.notifier);
  final added = await bookmarks.importBookmarks(parsed.bookmarks);
  var restoredFolders = 0;
  var failedFolders = 0;
  if (added >= 0) {
    for (final name in parsed.folders) {
      if (await folders.ensureFolder(name)) {
        restoredFolders++;
      } else {
        failedFolders++;
      }
    }
  }
  if (!context.mounted) return;
  final skippedNote = parsed.skipped > 0 ? ' (${parsed.skipped} skipped)' : '';
  final folderNote = failedFolders > 0
      ? ' ($failedFolders folders could not be restored)'
      : restoredFolders > 0
      ? ' (folders restored)'
      : '';
  final capacityNote = bookmarks.isAtCapacity() && parsed.bookmarks.isNotEmpty
      ? ' (limit of ${Bookmarks.maxBookmarks} reached; existing bookmarks kept)'
      : '';
  final resultMessage = added < 0
      ? 'Could not import bookmarks'
      : added > 0
      ? 'Imported $added bookmark${added == 1 ? '' : 's'}'
      : 'No new bookmarks';
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$resultMessage$skippedNote$folderNote$capacityNote'),
    ),
  );
}
