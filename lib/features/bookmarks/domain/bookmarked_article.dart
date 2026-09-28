import 'package:freezed_annotation/freezed_annotation.dart';

part 'bookmarked_article.freezed.dart';
part 'bookmarked_article.g.dart';

DateTime _savedAtFromJson(String value) => DateTime.parse(value);

String _savedAtToJson(DateTime value) => value.toUtc().toIso8601String();

/// A single bookmarked article, persisted to SharedPreferences.
///
/// [folder] is a user-assigned single-level label (null = Unsorted).
/// Entries written before folders existed have no `folder` key and load as null.
@freezed
abstract class BookmarkedArticle with _$BookmarkedArticle {
  const factory BookmarkedArticle({
    required String url,
    @Default('') String title,
    @JsonKey(fromJson: _savedAtFromJson, toJson: _savedAtToJson)
    required DateTime savedAt,
    String? folder,
  }) = _BookmarkedArticle;

  factory BookmarkedArticle.fromJson(Map<String, dynamic> json) =>
      _$BookmarkedArticleFromJson(json);
}
