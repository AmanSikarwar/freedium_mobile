import 'package:freezed_annotation/freezed_annotation.dart';

part 'reading_history.freezed.dart';
part 'reading_history.g.dart';

const readingCompletionThreshold = 0.95;
const readingProgressRestoreThreshold = 0.05;

double normalizeReadingProgress(double progress) {
  if (!progress.isFinite || progress <= readingProgressRestoreThreshold) {
    return 0;
  }
  if (progress >= readingCompletionThreshold) return 1;
  return progress.clamp(0, 1);
}

DateTime _dateTimeFromJson(String value) => DateTime.parse(value).toLocal();

String _dateTimeToJson(DateTime value) => value.toUtc().toIso8601String();

double _progressFromJson(num? value) =>
    normalizeReadingProgress(value?.toDouble() ?? 0);

@freezed
abstract class const ReadingHistory._() with _$ReadingHistory {
  const factory ReadingHistory({
    required String url,
    @Default('') String title,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    required DateTime timestamp,
    @JsonKey(fromJson: _progressFromJson) @Default(0) double progress,
  }) = _ReadingHistory;

  factory ReadingHistory.fromJson(Map<String, dynamic> json) =>
      _$ReadingHistoryFromJson(json);

  bool get isFinished => progress >= readingCompletionThreshold;
}
