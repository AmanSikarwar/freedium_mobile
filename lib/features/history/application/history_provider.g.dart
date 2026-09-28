// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(History)
final historyProvider = HistoryProvider._();

final class HistoryProvider
    extends $AsyncNotifierProvider<History, List<ReadingHistory>> {
  HistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyHash();

  @$internal
  @override
  History create() => History();
}

String _$historyHash() => r'3ce7d20093afd207b0ad7566d5898eae1d61b779';

abstract class _$History extends $AsyncNotifier<List<ReadingHistory>> {
  FutureOr<List<ReadingHistory>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<ReadingHistory>>, List<ReadingHistory>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ReadingHistory>>,
                List<ReadingHistory>
              >,
              AsyncValue<List<ReadingHistory>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Retention size (newest history entries kept) persisted to
/// SharedPreferences.

@ProviderFor(HistoryLimit)
final historyLimitProvider = HistoryLimitProvider._();

/// Retention size (newest history entries kept) persisted to
/// SharedPreferences.
final class HistoryLimitProvider
    extends $AsyncNotifierProvider<HistoryLimit, int> {
  /// Retention size (newest history entries kept) persisted to
  /// SharedPreferences.
  HistoryLimitProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyLimitProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyLimitHash();

  @$internal
  @override
  HistoryLimit create() => HistoryLimit();
}

String _$historyLimitHash() => r'a2fcafd52aedf0c7ddbff271bab6fca86ab82901';

/// Retention size (newest history entries kept) persisted to
/// SharedPreferences.

abstract class _$HistoryLimit extends $AsyncNotifier<int> {
  FutureOr<int> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<int>, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int>, int>,
              AsyncValue<int>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
