import 'package:flutter/material.dart';

@immutable
class ReadingHistory {
  final String url;
  final String title;
  final DateTime timestamp;

  const ReadingHistory({
    required this.url,
    required this.title,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ReadingHistory.fromJson(Map<String, dynamic> json) {
    return ReadingHistory(
      url: json['url'] as String,
      title: json['title'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ReadingHistory &&
      other.url == url &&
      other.title == title &&
      other.timestamp == timestamp;
  }

  @override
  int get hashCode => url.hashCode ^ title.hashCode ^ timestamp.hashCode;
}
