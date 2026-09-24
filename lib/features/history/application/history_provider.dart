import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/core/utils/url.dart' show normalizeHttpUrl;
import 'package:freedium_mobile/features/history/application/history_service.dart';
import 'package:freedium_mobile/features/history/domain/reading_history.dart';

part 'history_provider.g.dart';

@Riverpod(keepAlive: true)
class History extends _$History {
  static const int maxHistoryEntries = 100;

  Future<HistoryService?> _service() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      return HistoryService(prefs);
    } catch (e) {
      debugPrint('HistoryService unavailable: $e');
      return null;
    }
  }

  @override
  FutureOr<List<ReadingHistory>> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    return HistoryService(prefs).getHistory();
  }

  Future<void> addHistory(String url, String title) async {
    final service = await _service();
    if (service == null) return;
    final normalizedUrl = normalizeHttpUrl(url);
    if (normalizedUrl == null) return;
    final normalizedTitle = title.trim().isNotEmpty
        ? title.trim()
        : normalizedUrl;

    final current = state.value ?? const <ReadingHistory>[];
    final existingIndex = current.indexWhere(
      (item) => item.url == normalizedUrl,
    );
    final existingProgress = existingIndex < 0
        ? 0.0
        : current[existingIndex].progress;
    final newList = current.where((item) => item.url != normalizedUrl).toList();

    newList.insert(
      0,
      ReadingHistory(
        url: normalizedUrl,
        title: normalizedTitle,
        timestamp: DateTime.now(),
        progress: existingProgress,
      ),
    );

    if (newList.length > maxHistoryEntries) {
      newList.removeLast();
    }

    try {
      await service.saveHistory(newList);
      state = AsyncData(newList);
    } catch (e) {
      debugPrint('Failed to save history entry: $e');
    }
  }

  Future<double> readingProgressFor(String url) async {
    final service = await _service();
    if (service == null) return 0;
    final normalizedUrl = normalizeHttpUrl(url);
    if (normalizedUrl == null) return 0;

    final current = state.value ?? const <ReadingHistory>[];
    final index = current.indexWhere((item) => item.url == normalizedUrl);
    return index < 0 ? 0 : current[index].progress;
  }

  Future<void> updateReadingProgress(String url, double progress) async {
    final service = await _service();
    if (service == null) return;
    final normalizedUrl = normalizeHttpUrl(url);
    final normalizedProgress = normalizeReadingProgress(progress);
    if (normalizedUrl == null || normalizedProgress == 0) {
      return;
    }

    final current = state.value ?? const <ReadingHistory>[];
    final index = current.indexWhere((item) => item.url == normalizedUrl);
    if (index < 0 || current[index].progress == normalizedProgress) return;

    final newList = List<ReadingHistory>.from(current);
    newList[index] = newList[index].copyWith(progress: normalizedProgress);

    try {
      await service.saveHistory(newList);
      state = AsyncData(newList);
    } catch (e) {
      debugPrint('Failed to save reading progress: $e');
    }
  }

  Future<bool> removeHistory(ReadingHistory item) async {
    final service = await _service();
    if (service == null) return false;
    final current = state.value ?? const <ReadingHistory>[];
    final newList = current
        .where((element) => element.url != item.url)
        .toList();

    try {
      await service.saveHistory(newList);
      state = AsyncData(newList);
      return true;
    } catch (e) {
      debugPrint('Failed to remove history entry: $e');
      return false;
    }
  }

  Future<bool> clearHistory() async {
    final service = await _service();
    if (service == null) return false;
    try {
      await service.clearHistory();
      state = const AsyncData([]);
      return true;
    } catch (e) {
      debugPrint('Failed to clear history: $e');
      return false;
    }
  }
}
