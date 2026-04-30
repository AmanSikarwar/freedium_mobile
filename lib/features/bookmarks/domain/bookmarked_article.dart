import 'package:flutter/foundation.dart';

/// A single bookmarked article, persisted to SharedPreferences.
@immutable
class BookmarkedArticle {
  final String url;
  final String title;
  final DateTime savedAt;

  const BookmarkedArticle({
    required this.url,
    required this.title,
    required this.savedAt,
  });

  BookmarkedArticle copyWith({String? url, String? title, DateTime? savedAt}) {
    return BookmarkedArticle(
      url: url ?? this.url,
      title: title ?? this.title,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'title': title,
    'savedAt': savedAt.toIso8601String(),
  };

  factory BookmarkedArticle.fromJson(Map<String, dynamic> json) {
    return BookmarkedArticle(
      url: json['url'] as String,
      title: json['title'] as String? ?? '',
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookmarkedArticle &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;
}
