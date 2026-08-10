import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/core/utils/http_url_normalizer.dart';
import 'package:freedium_mobile/features/history/application/history_service.dart';
import 'package:freedium_mobile/features/history/domain/reading_history.dart';

class HistoryNotifier extends Notifier<List<ReadingHistory>> {
  HistoryService? _historyService;

  Future<HistoryService?> _ensureHistoryService() async {
    final existingService = _historyService;
    if (existingService != null) {
      return existingService;
    }

    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final service = HistoryService(prefs);
      _historyService = service;
      state = service.getHistory();
      return service;
    } catch (e) {
      debugPrint('HistoryService unavailable: $e');
      return null;
    }
  }

  @override
  List<ReadingHistory> build() {
    final prefsAsync = ref.watch(sharedPreferencesProvider);

    return prefsAsync.when(
      data: (prefs) {
        _historyService = HistoryService(prefs);
        return _historyService!.getHistory();
      },
      loading: () => const [],
      error: (e, _) {
        debugPrint('Failed to load SharedPreferences for history: $e');
        return const [];
      },
    );
  }

  Future<void> addHistory(String url, String title) async {
    final service = await _ensureHistoryService();
    if (service == null) return;
    final normalizedUrl = normalizeHttpUrl(url);
    if (normalizedUrl == null) return;
    final normalizedTitle = title.trim().isNotEmpty
        ? title.trim()
        : normalizedUrl;

    final prevState = state;
    final existingIndex = state.indexWhere((item) => item.url == normalizedUrl);
    final existingProgress = existingIndex < 0
        ? 0.0
        : state[existingIndex].progress;
    final newList = state.where((item) => item.url != normalizedUrl).toList();

    newList.insert(
      0,
      ReadingHistory(
        url: normalizedUrl,
        title: normalizedTitle,
        timestamp: DateTime.now(),
        progress: existingProgress,
      ),
    );

    if (newList.length > 100) {
      newList.removeLast();
    }

    try {
      await service.saveHistory(newList);
      state = newList;
    } catch (e) {
      debugPrint('Failed to save history entry: $e');
      state = prevState;
    }
  }

  Future<double> readingProgressFor(String url) async {
    await _ensureHistoryService();
    final normalizedUrl = normalizeHttpUrl(url);
    if (normalizedUrl == null) return 0;

    final index = state.indexWhere((item) => item.url == normalizedUrl);
    return index < 0 ? 0 : state[index].progress;
  }

  Future<void> updateReadingProgress(String url, double progress) async {
    final service = await _ensureHistoryService();
    final normalizedUrl = normalizeHttpUrl(url);
    final normalizedProgress = normalizeReadingProgress(progress);
    if (service == null || normalizedUrl == null || normalizedProgress == 0) {
      return;
    }

    final index = state.indexWhere((item) => item.url == normalizedUrl);
    if (index < 0 || state[index].progress == normalizedProgress) return;

    final previousState = state;
    final newList = List<ReadingHistory>.from(state);
    newList[index] = newList[index].copyWith(progress: normalizedProgress);

    try {
      await service.saveHistory(newList);
      state = newList;
    } catch (e) {
      debugPrint('Failed to save reading progress: $e');
      state = previousState;
    }
  }

  Future<bool> removeHistory(ReadingHistory item) async {
    final service = await _ensureHistoryService();
    if (service == null) return false;

    final prevState = state;
    final newList = state.where((element) => element.url != item.url).toList();

    try {
      await service.saveHistory(newList);
      state = newList;
      return true;
    } catch (e) {
      debugPrint('Failed to remove history entry: $e');
      state = prevState;
      return false;
    }
  }

  Future<bool> clearHistory() async {
    final service = await _ensureHistoryService();
    if (service == null) return false;

    final prevState = state;

    try {
      await service.clearHistory();
      state = [];
      return true;
    } catch (e) {
      debugPrint('Failed to clear history: $e');
      state = prevState;
      return false;
    }
  }
}

final historyProvider = NotifierProvider<HistoryNotifier, List<ReadingHistory>>(
  HistoryNotifier.new,
);
