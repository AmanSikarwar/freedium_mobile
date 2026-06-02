import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freedium_mobile/features/history/domain/reading_history.dart';

class HistoryService {
  static const String _historyKey = 'reading_history';
  final SharedPreferences _prefs;

  HistoryService(this._prefs);

  List<ReadingHistory> getHistory() {
    final historyJson = _prefs.getStringList(_historyKey);
    if (historyJson == null) return [];

    final List<ReadingHistory> history = [];
    final seenUrls = <String>{};
    for (final json in historyJson) {
      try {
        final decoded = jsonDecode(json) as Map<String, dynamic>;
        final item = ReadingHistory.fromJson(decoded);
        final url = item.url.trim();
        final uri = Uri.tryParse(url);
        final scheme = uri?.scheme.toLowerCase();
        if (uri == null ||
            uri.host.isEmpty ||
            (scheme != 'http' && scheme != 'https') ||
            !seenUrls.add(url)) {
          continue;
        }
        final title = item.title.trim();
        history.add(
          ReadingHistory(
            url: url,
            title: title.isNotEmpty ? title : url,
            timestamp: item.timestamp,
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
      final success = await _prefs.setStringList(_historyKey, historyJson);
      if (!success) {
        throw Exception('setStringList returned false for key "$_historyKey"');
      }
    } catch (e) {
      debugPrint('Failed to save history to "$_historyKey": $e');
      rethrow;
    }
  }

  Future<void> clearHistory() async {
    try {
      final success = await _prefs.remove(_historyKey);
      if (!success) {
        throw Exception('remove returned false for key "$_historyKey"');
      }
    } catch (e) {
      debugPrint('Failed to clear history key "$_historyKey": $e');
      rethrow;
    }
  }
}
