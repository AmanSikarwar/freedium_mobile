// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmarks_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Bookmarks)
final bookmarksProvider = BookmarksProvider._();

final class BookmarksProvider
    extends $AsyncNotifierProvider<Bookmarks, List<BookmarkedArticle>> {
  BookmarksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookmarksProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookmarksHash();

  @$internal
  @override
  Bookmarks create() => Bookmarks();
}

String _$bookmarksHash() => r'02fea85838bf7b28a57c469197e1f9fb2ee8407b';

abstract class _$Bookmarks extends $AsyncNotifier<List<BookmarkedArticle>> {
  FutureOr<List<BookmarkedArticle>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<BookmarkedArticle>>,
              List<BookmarkedArticle>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<BookmarkedArticle>>,
                List<BookmarkedArticle>
              >,
              AsyncValue<List<BookmarkedArticle>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
