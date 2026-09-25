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

String _$bookmarksHash() => r'0999859507282925fa5f8303248b7e4319a69d26';

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

/// Stored bookmark folder list plus coordination with article folders.
///
/// The UI-facing list is [allBookmarkFoldersProvider]: the union of stored
/// folders and folders referenced by articles.

@ProviderFor(BookmarkFolders)
final bookmarkFoldersProvider = BookmarkFoldersProvider._();

/// Stored bookmark folder list plus coordination with article folders.
///
/// The UI-facing list is [allBookmarkFoldersProvider]: the union of stored
/// folders and folders referenced by articles.
final class BookmarkFoldersProvider
    extends $AsyncNotifierProvider<BookmarkFolders, List<String>> {
  /// Stored bookmark folder list plus coordination with article folders.
  ///
  /// The UI-facing list is [allBookmarkFoldersProvider]: the union of stored
  /// folders and folders referenced by articles.
  BookmarkFoldersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookmarkFoldersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookmarkFoldersHash();

  @$internal
  @override
  BookmarkFolders create() => BookmarkFolders();
}

String _$bookmarkFoldersHash() => r'fa54045c069b59c490704bc50614dde0640f2052';

/// Stored bookmark folder list plus coordination with article folders.
///
/// The UI-facing list is [allBookmarkFoldersProvider]: the union of stored
/// folders and folders referenced by articles.

abstract class _$BookmarkFolders extends $AsyncNotifier<List<String>> {
  FutureOr<List<String>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<String>>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<String>>, List<String>>,
              AsyncValue<List<String>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Union of stored folders and folders referenced by bookmarked articles,
/// for filter chips and pickers.

@ProviderFor(allBookmarkFolders)
final allBookmarkFoldersProvider = AllBookmarkFoldersProvider._();

/// Union of stored folders and folders referenced by bookmarked articles,
/// for filter chips and pickers.

final class AllBookmarkFoldersProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  /// Union of stored folders and folders referenced by bookmarked articles,
  /// for filter chips and pickers.
  AllBookmarkFoldersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allBookmarkFoldersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allBookmarkFoldersHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return allBookmarkFolders(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$allBookmarkFoldersHash() =>
    r'71b240d501b5936859e7df447eb74155af86222b';
