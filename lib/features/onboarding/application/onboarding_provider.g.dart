// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Onboarding)
final onboardingProvider = OnboardingProvider._();

final class OnboardingProvider
    extends $NotifierProvider<Onboarding, OnboardingState> {
  OnboardingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingHash();

  @$internal
  @override
  Onboarding create() => Onboarding();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingState>(value),
    );
  }
}

String _$onboardingHash() => r'e84ef2023d36cdb716822ed9c1d201a4dd97404f';

abstract class _$Onboarding extends $Notifier<OnboardingState> {
  OnboardingState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<OnboardingState, OnboardingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OnboardingState, OnboardingState>,
              OnboardingState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(onboardingService)
final onboardingServiceProvider = OnboardingServiceProvider._();

final class OnboardingServiceProvider
    extends
        $FunctionalProvider<
          OnboardingService?,
          OnboardingService?,
          OnboardingService?
        >
    with $Provider<OnboardingService?> {
  OnboardingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingServiceHash();

  @$internal
  @override
  $ProviderElement<OnboardingService?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OnboardingService? create(Ref ref) {
    return onboardingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingService? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingService?>(value),
    );
  }
}

String _$onboardingServiceHash() => r'f7d7db036ed9995e7306f3b933c6e7cdd7b6c1b8';
