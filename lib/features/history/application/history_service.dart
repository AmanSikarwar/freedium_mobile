import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freedium_mobile/features/history/domain/reading_history.dart';

class HistoryService {
  static const String _historyKey = 'reading_history';
  final SharedPreferences _prefs;

  HistoryService(this._prefs);

  List<ReadingHistory> getHistory() {
    final historyJson = _prefs.getStringList(_historyKey);
    if (historyJson == null) return [];

    try {
      return historyJson
          .map(
            (json) => ReadingHistory.fromJson(
              jsonDecode(json) as Map<String, dynamic>,
            ),
          )
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      return [];
    }
  }

  Future<void> saveHistory(List<ReadingHistory> history) async {
    final historyJson = history.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(_historyKey, historyJson);
  }

  Future<void> clearHistory() async {
    await _prefs.remove(_historyKey);
  }
}
