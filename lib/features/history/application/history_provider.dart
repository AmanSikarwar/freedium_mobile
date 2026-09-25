import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/core/utils/url.dart' show normalizeHttpUrl;
import 'package:freedium_mobile/features/history/application/history_service.dart';
import 'package:freedium_mobile/features/history/domain/reading_history.dart';

part 'history_provider.g.dart';

@Riverpod(keepAlive: true)
class History() extends _$History {
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
    final service = HistoryService(prefs);
    final history = service.getHistory();
    final limit = service.getHistoryLimit();
    if (history.length <= limit) return history;
    final trimmed = history.sublist(0, limit);
    try {
      await service.saveHistory(trimmed);
    } catch (e) {
      debugPrint('Failed to trim history to limit: $e');
    }
    return trimmed;
  }

  /// Current retention size (newest entries kept).
  int historyLimit() {
    return ref.read(historyLimitProvider).value ?? HistoryService.defaultLimit;
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

    final limit = service.getHistoryLimit();
    if (newList.length > limit) {
      newList.removeRange(limit, newList.length);
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

  /// Trims the list to [limit] newest entries and persists. Used when the
  /// retention setting changes.
  Future<bool> applyLimit(int limit) async {
    final service = await _service();
    if (service == null) return false;

    final current = state.value ?? const <ReadingHistory>[];
    final newList = current.length > limit
        ? current.sublist(0, limit)
        : current;
    if (identical(newList, current)) return true;

    try {
      await service.saveHistory(newList);
      state = AsyncData(newList);
      return true;
    } catch (e) {
      debugPrint('Failed to trim history: $e');
      return false;
    }
  }

  /// Removes entries older than [maxAge] and persists.
  /// Returns the number of entries removed, or -1 on failure.
  Future<int> clearOlderThan(Duration maxAge) async {
    final service = await _service();
    if (service == null) return -1;

    final cutoff = DateTime.now().subtract(maxAge);
    final current = state.value ?? const <ReadingHistory>[];
    final newList = current
        .where((item) => item.timestamp.isAfter(cutoff))
        .toList();
    final removed = current.length - newList.length;
    if (removed == 0) return 0;

    try {
      await service.saveHistory(newList);
      state = AsyncData(newList);
      return removed;
    } catch (e) {
      debugPrint('Failed to clear old history: $e');
      return -1;
    }
  }
}

/// Retention size (newest history entries kept) persisted to
/// SharedPreferences.
@Riverpod(keepAlive: true)
class HistoryLimit() extends _$HistoryLimit {
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
  FutureOr<int> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    return HistoryService(prefs).getHistoryLimit();
  }

  /// Persists [limit] and trims history to match. Returns false when the
  /// value is unsupported or persistence fails.
  Future<bool> setLimit(int limit) async {
    final service = await _service();
    if (service == null) return false;
    if (!HistoryService.allowedLimits.contains(limit)) return false;

    try {
      await service.saveHistoryLimit(limit);
    } catch (e) {
      debugPrint('Failed to save history limit: $e');
      return false;
    }
    final trimmed = await ref.read(historyProvider.notifier).applyLimit(limit);
    state = AsyncData(limit);
    return trimmed;
  }
}
