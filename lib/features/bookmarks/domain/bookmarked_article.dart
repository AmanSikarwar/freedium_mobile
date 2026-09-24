import 'package:freezed_annotation/freezed_annotation.dart';

part 'bookmarked_article.freezed.dart';
part 'bookmarked_article.g.dart';

DateTime _savedAtFromJson(String value) => DateTime.parse(value);

String _savedAtToJson(DateTime value) => value.toUtc().toIso8601String();

/// A single bookmarked article, persisted to SharedPreferences.
@freezed
abstract class BookmarkedArticle with _$BookmarkedArticle {
  const factory BookmarkedArticle({
    required String url,
    @Default('') String title,
    @JsonKey(fromJson: _savedAtFromJson, toJson: _savedAtToJson)
    required DateTime savedAt,
  }) = _BookmarkedArticle;

  factory BookmarkedArticle.fromJson(Map<String, dynamic> json) =>
      _$BookmarkedArticleFromJson(json);
}
