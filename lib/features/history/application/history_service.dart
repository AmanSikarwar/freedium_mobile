import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:freedium_mobile/core/utils/url.dart' show normalizeHttpUrl;
import 'package:freedium_mobile/features/history/domain/reading_history.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService(this._prefs) {
  static const String _historyKey = 'reading_history';
  static const String _historyLimitKey = 'history_limit';
  static const String _progressPrefix = 'reading_progress_v1:';

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
        final progress = _prefs.get(_progressKey(url, item.timestamp));
        history.add(
          ReadingHistory(
            url: url,
            title: title.isNotEmpty ? title : url,
            timestamp: item.timestamp,
            progress: progress is num
                ? normalizeReadingProgress(progress.toDouble())
                : item.progress,
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
    await _pruneProgress(history);
  }

  String _progressKey(String url, DateTime timestamp) =>
      '$_progressPrefix${timestamp.microsecondsSinceEpoch}:$url';

  Future<void> saveReadingProgress(ReadingHistory item, double progress) async {
    try {
      await _prefs.setDouble(
        _progressKey(item.url, item.timestamp),
        normalizeReadingProgress(progress),
      );
    } catch (_) {
      await _prefs.reloadCache();
      rethrow;
    }
  }

  Future<void> _pruneProgress(List<ReadingHistory> history) async {
    final retained = history
        .map((item) => _progressKey(item.url, item.timestamp))
        .toSet();
    for (final key in _prefs.keys.where(
      (key) => key.startsWith(_progressPrefix),
    )) {
      if (retained.contains(key)) continue;
      try {
        await _prefs.remove(key);
      } catch (e) {
        // Visit-specific keys make failed cleanup safe to retry.
        debugPrint('Failed to remove old reading progress: $e');
      }
    }
  }

  Future<void> clearHistory() async {
    try {
      await _prefs.remove(_historyKey);
    } catch (e) {
      debugPrint('Failed to clear history key "$_historyKey": $e');
      rethrow;
    }
    await _pruneProgress(const []);
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
