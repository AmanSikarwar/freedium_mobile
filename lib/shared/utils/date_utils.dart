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

  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  if (diff < 7) return 'This week';
  if (diff < 30) return 'This month';

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
/// `(groupLabel, item)` entries for use with a sectioned ListView.
///
/// [dateOf] extracts the [DateTime] from each item.
List<Object> buildGroupedList<T extends Object>({
  required List<T> items,
  required DateTime Function(T) dateOf,
}) {
  final result = <Object>[];
  String? lastLabel;

  for (final item in items) {
    final label = dateGroupLabel(dateOf(item));
    if (label != lastLabel) {
      result.add(label); // header sentinel — a String
      lastLabel = label;
    }
    result.add(item);
  }

  return result;
}
