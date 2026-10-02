import 'dart:convert';

import 'package:freedium_mobile/core/utils/url.dart' show normalizeHttpUrl;
import 'package:freedium_mobile/features/bookmarks/domain/bookmark_folder.dart';
import 'package:freedium_mobile/features/bookmarks/domain/bookmarked_article.dart';

// JSON backup format for bookmarks, versioned for forward compatibility:
//
// {
//   "version": 1,
//   "folders": ["Tech"],
//   "bookmarks": [
//     {
//       "url": "https://medium.com/...",
//       "title": "...",
//       "savedAt": "2026-01-01T00:00:00.000Z",
//       "folder": "Tech" | null
//     }
//   ]
// }

/// Current backup format version written by [exportBookmarksJson].
const int bookmarkBackupVersion = 1;

/// Serializes [bookmarks] and [folders] to a shareable JSON string.
String exportBookmarksJson(
  List<BookmarkedArticle> bookmarks,
  List<String> folders,
) {
  return const JsonEncoder.withIndent('  ').convert({
    'version': bookmarkBackupVersion,
    'folders': mergeBookmarkFolders(folders, const []),
    'bookmarks': [
      for (final b in bookmarks)
        {
          'url': b.url,
          'title': b.title,
          'savedAt': b.savedAt.toUtc().toIso8601String(),
          if (b.folder != null) 'folder': b.folder,
        },
    ],
  });
}

/// Result of parsing a bookmark backup.
class const BookmarkImport({
  required this.bookmarks,
  required this.folders,
  required this.skipped,
}) {
  final List<BookmarkedArticle> bookmarks;
  final List<String> folders;

  /// Entries dropped for missing/invalid URLs.
  final int skipped;
}

/// Parses a backup produced by [exportBookmarksJson].
///
/// Throws [FormatException] when [raw] is not JSON or not a bookmark backup.
/// Unknown fields are ignored; malformed entries count toward [skipped].
BookmarkImport parseBookmarksJson(String raw) {
  if (raw.length > 1024 * 1024) {
    throw const FormatException('Bookmark backup is too large');
  }
  final decoded = jsonDecode(raw);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Bookmark backup must be a JSON object');
  }
  if (decoded['version'] is! int ||
      decoded['version'] != bookmarkBackupVersion) {
    throw const FormatException('Unsupported bookmark backup version');
  }
  final entries = decoded['bookmarks'];
  if (entries is! List) {
    throw const FormatException('Bookmark backup is missing "bookmarks"');
  }
  final rawFolders = decoded['folders'];
  if (rawFolders != null &&
      (rawFolders is! List || rawFolders.any((name) => name is! String))) {
    throw const FormatException('Bookmark folders must be a list of names');
  }
  final folders = mergeBookmarkFolders(
    rawFolders is List ? rawFolders.cast<String>() : const [],
    const [],
  );

  final bookmarks = <BookmarkedArticle>[];
  var skipped = 0;
  for (final entry in entries) {
    if (entry is! Map<String, dynamic>) {
      skipped++;
      continue;
    }
    final rawUrl = entry['url'];
    final rawTitle = entry['title'];
    final rawFolder = entry['folder'];
    final rawDate = entry['savedAt'];
    if (rawUrl is! String ||
        (rawTitle != null && rawTitle is! String) ||
        (rawFolder != null && rawFolder is! String) ||
        (rawDate != null && rawDate is! String)) {
      skipped++;
      continue;
    }
    final url = normalizeHttpUrl(rawUrl);
    if (url == null) {
      skipped++;
      continue;
    }
    final title = rawTitle is String ? rawTitle.trim() : '';
    final savedAt =
        (rawDate is String ? DateTime.tryParse(rawDate) : null) ??
        DateTime.now().toUtc();
    bookmarks.add(
      BookmarkedArticle(
        url: url,
        title: title.isNotEmpty ? title : url,
        savedAt: savedAt,
        folder: rawFolder is String
            ? normalizeBookmarkFolderName(rawFolder)
            : null,
      ),
    );
  }
  return BookmarkImport(
    bookmarks: bookmarks,
    folders: folders,
    skipped: skipped,
  );
}
