// Shared rules for bookmark folders (single-level user labels).
//
// Folders live in two places: an explicit stored list (`bookmark_folders`
// SharedPreferences key) and the `folder` field on `BookmarkedArticle`.
// The UI shows the union of both so folders referenced by articles always
// appear even if the stored list is missing entries.

/// Maximum number of stored folders.
const int maxBookmarkFolders = 50;

/// Maximum length of a single folder name.
const int maxBookmarkFolderNameLength = 40;

/// Normalizes a folder name: trims, maps empty to null, truncates to
/// [maxBookmarkFolderNameLength]. Returns null for Unsorted.
String? normalizeBookmarkFolderName(String? name) {
  final trimmed = name?.trim() ?? '';
  if (trimmed.isEmpty) return null;
  if (trimmed.length <= maxBookmarkFolderNameLength) return trimmed;
  return trimmed.substring(0, maxBookmarkFolderNameLength);
}

/// Merges stored and article-referenced folders: trims, drops empties,
/// dedups case-insensitively (first-seen casing wins), sorts
/// case-insensitively.
List<String> mergeBookmarkFolders(
  Iterable<String?> stored,
  Iterable<String?> referenced,
) {
  final seen = <String>{};
  final merged = <String>[];
  for (final name in [...stored, ...referenced]) {
    final normalized = normalizeBookmarkFolderName(name);
    if (normalized == null) continue;
    if (seen.add(normalized.toLowerCase())) {
      merged.add(normalized);
    }
  }
  merged.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return merged;
}

/// Returns true if [name] (unnormalized) duplicates [existing] (normalized
/// list), ignoring case. [exclude] skips one entry (for renames).
bool isBookmarkFolderDuplicate(
  String name,
  List<String> existing, {
  String? exclude,
}) {
  final normalized = normalizeBookmarkFolderName(name);
  if (normalized == null) return false;
  final lower = normalized.toLowerCase();
  final excluded = normalizeBookmarkFolderName(exclude)?.toLowerCase();
  return existing.any(
    (e) => e.toLowerCase() == lower && e.toLowerCase() != excluded,
  );
}
