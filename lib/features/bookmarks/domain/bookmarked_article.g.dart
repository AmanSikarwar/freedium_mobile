// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmarked_article.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookmarkedArticle _$BookmarkedArticleFromJson(Map<String, dynamic> json) =>
    _BookmarkedArticle(
      url: json['url'] as String,
      title: json['title'] as String? ?? '',
      savedAt: _savedAtFromJson(json['savedAt'] as String),
    );

Map<String, dynamic> _$BookmarkedArticleToJson(_BookmarkedArticle instance) =>
    <String, dynamic>{
      'url': instance.url,
      'title': instance.title,
      'savedAt': _savedAtToJson(instance.savedAt),
    };
