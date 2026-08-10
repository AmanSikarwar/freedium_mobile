import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/features/history/application/history_service.dart';
import 'package:freedium_mobile/features/history/domain/reading_history.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('HistoryService', () {
    test('getHistory skips invalid and duplicate history entries', () async {
      final timestamp = DateTime.utc(2026, 2, 3);
      final history = ReadingHistory(
        url: 'https://medium.com/example/story',
        title: 'Example story',
        timestamp: timestamp.toLocal(),
      );

      SharedPreferences.setMockInitialValues({
        'reading_history': [
          '{bad json',
          jsonEncode({
            'url': '',
            'title': 'Blank URL',
            'timestamp': timestamp.toIso8601String(),
          }),
          jsonEncode({
            'url': 'ftp://example.com/story',
            'title': 'Unsupported scheme',
            'timestamp': timestamp.toIso8601String(),
          }),
          jsonEncode(history.toJson()),
          jsonEncode({
            'url': ' HTTPS://Medium.COM/example/story/ ',
            'title': 'Duplicate',
            'timestamp': timestamp
                .add(const Duration(minutes: 1))
                .toIso8601String(),
          }),
        ],
      });

      final prefs = await SharedPreferences.getInstance();
      final service = HistoryService(prefs);

      expect(service.getHistory(), [history]);
    });

    test('getHistory falls back to URL when title is blank', () async {
      final timestamp = DateTime.utc(2026, 2, 3);
      SharedPreferences.setMockInitialValues({
        'reading_history': [
          jsonEncode({
            'url': ' HTTPS://Medium.COM/example/story/ ',
            'title': ' ',
            'timestamp': timestamp.toIso8601String(),
          }),
        ],
      });

      final prefs = await SharedPreferences.getInstance();
      final service = HistoryService(prefs);

      final history = service.getHistory();
      expect(history, hasLength(1));
      expect(history.single.title, 'https://medium.com/example/story');
    });

    test('getHistory falls back to URL when title is missing', () async {
      final timestamp = DateTime.utc(2026, 2, 3);
      SharedPreferences.setMockInitialValues({
        'reading_history': [
          jsonEncode({
            'url': 'https://medium.com/example/story',
            'timestamp': timestamp.toIso8601String(),
          }),
        ],
      });

      final prefs = await SharedPreferences.getInstance();
      final service = HistoryService(prefs);

      final history = service.getHistory();
      expect(history, hasLength(1));
      expect(history.single.title, 'https://medium.com/example/story');
    });

    test('getHistory loads progress and supports legacy entries', () async {
      final timestamp = DateTime.utc(2026, 2, 3);
      SharedPreferences.setMockInitialValues({
        'reading_history': [
          jsonEncode({
            'url': 'https://medium.com/with-progress',
            'title': 'With progress',
            'timestamp': timestamp.toIso8601String(),
            'progress': 0.42,
          }),
          jsonEncode({
            'url': 'https://medium.com/legacy',
            'title': 'Legacy',
            'timestamp': timestamp
                .subtract(const Duration(minutes: 1))
                .toIso8601String(),
          }),
        ],
      });

      final prefs = await SharedPreferences.getInstance();
      final history = HistoryService(prefs).getHistory();

      expect(history.first.progress, 0.42);
      expect(history.last.progress, 0);
    });
  });
}
