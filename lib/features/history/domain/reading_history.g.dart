// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReadingHistory _$ReadingHistoryFromJson(Map<String, dynamic> json) =>
    _ReadingHistory(
      url: json['url'] as String,
      title: json['title'] as String? ?? '',
      timestamp: _dateTimeFromJson(json['timestamp'] as String),
      progress: json['progress'] == null
          ? 0
          : _progressFromJson(json['progress'] as num?),
    );

Map<String, dynamic> _$ReadingHistoryToJson(_ReadingHistory instance) =>
    <String, dynamic>{
      'url': instance.url,
      'title': instance.title,
      'timestamp': _dateTimeToJson(instance.timestamp),
      'progress': instance.progress,
    };
