import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:freedium_mobile/core/utils/url.dart' show normalizeHttpUrl;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freedium_mobile/features/history/domain/reading_history.dart';

class HistoryService(this._prefs) {
  static const String _historyKey = 'reading_history';
  static const String _historyLimitKey = 'history_limit';

  /// Allowed retention sizes (newest entries kept).
  static const List<int> allowedLimits = [30, 100, 500];

  /// Default retention size.
  static const int defaultLimit = 100;
  final SharedPreferencesWithCache _prefs;

  List<ReadingHistory> getHistory() {
    final historyJson = _prefs.getStringList(_historyKey);
    if (historyJson == null) return [];

    final List<ReadingHistory> history = [];
    final seenUrls = <String>{};
    for (final json in historyJson) {
      try {
        final decoded = jsonDecode(json) as Map<String, dynamic>;
        final item = ReadingHistory.fromJson(decoded);
        final url = normalizeHttpUrl(item.url);
        if (url == null || !seenUrls.add(url)) {
          continue;
        }
        final title = item.title.trim();
        history.add(
          ReadingHistory(
            url: url,
            title: title.isNotEmpty ? title : url,
            timestamp: item.timestamp,
            progress: item.progress,
          ),
        );
      } catch (e) {
        debugPrint('Failed to parse history entry: $e');
      }
    }

    history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return history;
  }

  Future<void> saveHistory(List<ReadingHistory> history) async {
    try {
      final historyJson = history.map((e) => jsonEncode(e.toJson())).toList();
      await _prefs.setStringList(_historyKey, historyJson);
    } catch (e) {
      debugPrint('Failed to save history to "$_historyKey": $e');
      rethrow;
    }
  }

  Future<void> clearHistory() async {
    try {
      await _prefs.remove(_historyKey);
    } catch (e) {
      debugPrint('Failed to clear history key "$_historyKey": $e');
      rethrow;
    }
  }

  /// Reads the retention size, falling back to [defaultLimit] for missing
  /// or unrecognized values.
  int getHistoryLimit() {
    final stored = _prefs.getInt(_historyLimitKey);
    if (stored != null && allowedLimits.contains(stored)) return stored;
    return defaultLimit;
  }

  Future<void> saveHistoryLimit(int limit) async {
    if (!allowedLimits.contains(limit)) {
      throw ArgumentError.value(limit, 'limit', 'Unsupported history limit');
    }
    try {
      await _prefs.setInt(_historyLimitKey, limit);
    } catch (e) {
      debugPrint('Failed to save history limit: $e');
      rethrow;
    }
  }
}
