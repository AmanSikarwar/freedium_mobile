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

String _$historyHash() => r'fd4c7d7e898cdaae14582761b03a231e7ec443fc';

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
