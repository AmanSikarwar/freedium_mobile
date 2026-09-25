// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webview_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Webview)
final webviewProvider = WebviewFamily._();

final class WebviewProvider extends $NotifierProvider<Webview, WebviewState> {
  WebviewProvider._({
    required WebviewFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'webviewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$webviewHash();

  @override
  String toString() {
    return r'webviewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Webview create() => Webview();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WebviewState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WebviewState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is WebviewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$webviewHash() => r'a686a8cdf94ad5ba51c513d851b7e1a6b4ed5089';

final class WebviewFamily extends $Family
    with
        $ClassFamilyOverride<
          Webview,
          WebviewState,
          WebviewState,
          WebviewState,
          String
        > {
  WebviewFamily._()
    : super(
        retry: null,
        name: r'webviewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WebviewProvider call(String url) =>
      WebviewProvider._(argument: url, from: this);

  @override
  String toString() => r'webviewProvider';
}

abstract class _$Webview extends $Notifier<WebviewState> {
  late final _$args = ref.$arg as String;
  String get url => _$args;

  WebviewState build(String url);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WebviewState, WebviewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WebviewState, WebviewState>,
              WebviewState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(themeInjectorService)
final themeInjectorServiceProvider = ThemeInjectorServiceProvider._();

final class ThemeInjectorServiceProvider
    extends
        $FunctionalProvider<
          ThemeInjectorService,
          ThemeInjectorService,
          ThemeInjectorService
        >
    with $Provider<ThemeInjectorService> {
  ThemeInjectorServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeInjectorServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeInjectorServiceHash();

  @$internal
  @override
  $ProviderElement<ThemeInjectorService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ThemeInjectorService create(Ref ref) {
    return themeInjectorService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeInjectorService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeInjectorService>(value),
    );
  }
}

String _$themeInjectorServiceHash() =>
    r'9d8b3b39c22b01af59f2fe322b8a22379f33ec6c';

@ProviderFor(shareLauncher)
final shareLauncherProvider = ShareLauncherProvider._();

final class ShareLauncherProvider
    extends $FunctionalProvider<ShareLauncher, ShareLauncher, ShareLauncher>
    with $Provider<ShareLauncher> {
  ShareLauncherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shareLauncherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shareLauncherHash();

  @$internal
  @override
  $ProviderElement<ShareLauncher> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ShareLauncher create(Ref ref) {
    return shareLauncher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShareLauncher value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShareLauncher>(value),
    );
  }
}

String _$shareLauncherHash() => r'640b46fd5b2a75e541bb4653a3703b5d86785ca3';
