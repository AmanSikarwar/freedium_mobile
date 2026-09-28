// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intent_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(intentService)
final intentServiceProvider = IntentServiceProvider._();

final class IntentServiceProvider
    extends $FunctionalProvider<IntentService, IntentService, IntentService>
    with $Provider<IntentService> {
  IntentServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'intentServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$intentServiceHash();

  @$internal
  @override
  $ProviderElement<IntentService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IntentService create(Ref ref) {
    return intentService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IntentService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IntentService>(value),
    );
  }
}

String _$intentServiceHash() => r'8a038f2d047fe0721f7528a45d8a9956d2c7ff1f';

@ProviderFor(intentStream)
final intentStreamProvider = IntentStreamProvider._();

final class IntentStreamProvider
    extends $FunctionalProvider<AsyncValue<String>, String, Stream<String>>
    with $FutureModifier<String>, $StreamProvider<String> {
  IntentStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'intentStreamProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$intentStreamHash();

  @$internal
  @override
  $StreamProviderElement<String> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String> create(Ref ref) {
    return intentStream(ref);
  }
}

String _$intentStreamHash() => r'b00a835b4d80a1c308e03518f65afea37fd3bd01';
