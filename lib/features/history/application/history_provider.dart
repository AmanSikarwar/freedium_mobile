import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
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
      error: (_, _) => const [],
    );
  }

  Future<void> addHistory(String url, String title) async {
    final service = await _ensureHistoryService();
    if (service == null) return;

    final newList = state.where((item) => item.url != url).toList();

    newList.insert(
      0,
      ReadingHistory(url: url, title: title, timestamp: DateTime.now()),
    );

    if (newList.length > 100) {
      newList.removeLast();
    }

    state = newList;
    await service.saveHistory(state);
  }

  Future<void> removeHistory(ReadingHistory item) async {
    final service = await _ensureHistoryService();
    if (service == null) return;

    final newList = state.where((element) => element.url != item.url).toList();
    state = newList;
    await service.saveHistory(state);
  }

  Future<void> clearHistory() async {
    final service = await _ensureHistoryService();
    if (service == null) return;

    state = [];
    await service.clearHistory();
  }
}

final historyProvider = NotifierProvider<HistoryNotifier, List<ReadingHistory>>(
  HistoryNotifier.new,
);
