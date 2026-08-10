import 'package:flutter/material.dart';

const readingCompletionThreshold = 0.95;
const readingProgressRestoreThreshold = 0.05;

double normalizeReadingProgress(double progress) {
  if (!progress.isFinite || progress <= readingProgressRestoreThreshold) {
    return 0;
  }
  if (progress >= readingCompletionThreshold) return 1;
  return progress.clamp(0, 1);
}

@immutable
class ReadingHistory {
  final String url;
  final String title;
  final DateTime timestamp;
  final double progress;

  const ReadingHistory({
    required this.url,
    required this.title,
    required this.timestamp,
    this.progress = 0,
  });

  bool get isFinished => progress >= readingCompletionThreshold;

  ReadingHistory copyWith({
    String? url,
    String? title,
    DateTime? timestamp,
    double? progress,
  }) {
    return ReadingHistory(
      url: url ?? this.url,
      title: title ?? this.title,
      timestamp: timestamp ?? this.timestamp,
      progress: progress ?? this.progress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'progress': progress,
    };
  }

  factory ReadingHistory.fromJson(Map<String, dynamic> json) {
    return ReadingHistory(
      url: json['url'] as String,
      title: json['title'] as String? ?? '',
      timestamp: DateTime.parse(json['timestamp'] as String).toLocal(),
      progress: normalizeReadingProgress(
        (json['progress'] as num?)?.toDouble() ?? 0,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReadingHistory &&
        other.url == url &&
        other.title == title &&
        other.timestamp == timestamp &&
        other.progress == progress;
  }

  @override
  int get hashCode => Object.hash(url, title, timestamp, progress);
}
