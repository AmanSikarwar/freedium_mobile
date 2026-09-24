/// Utilities for grouping dated items into human-readable date sections.
library;

import 'package:timeago/timeago.dart' as timeago;

/// Returns a human-readable group label for the given [date].
/// Groups: Today, Yesterday, This week, This month, then month-year.
String dateGroupLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(date.year, date.month, date.day);
  final diff = today.difference(d).inDays;

  switch (diff) {
    case 0:
      return 'Today';
    case 1:
      return 'Yesterday';
    case < 7:
      return 'This week';
    case < 30:
      return 'This month';
    default:
      break;
  }

  // E.g. "March 2025"
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.year}';
}

/// Returns a relative time string like "3 minutes ago".
String relativeTime(DateTime date) => timeago.format(date);

/// Groups a list of [items] (sorted newest-first) into an ordered list of
/// `(groupLabel, item)` records for use with a sectioned ListView.
///
/// Each entry carries its own group label so callers can render a header
/// when the label differs from the previous entry — no `String` sentinel
/// or casts required.
///
/// [dateOf] extracts the [DateTime] from each item.
List<(String, T)> buildGroupedList<T extends Object>({
  required List<T> items,
  required DateTime Function(T) dateOf,
}) {
  return [
    for (final item in items) (dateGroupLabel(dateOf(item)), item),
  ];
}
