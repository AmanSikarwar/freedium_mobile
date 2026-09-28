// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FreediumMirror _$FreediumMirrorFromJson(Map<String, dynamic> json) =>
    _FreediumMirror(
      name: json['name'] as String,
      url: json['url'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
      isCustom: json['isCustom'] as bool? ?? false,
    );

Map<String, dynamic> _$FreediumMirrorToJson(_FreediumMirror instance) =>
    <String, dynamic>{
      'name': instance.name,
      'url': instance.url,
      'isDefault': instance.isDefault,
      'isCustom': instance.isCustom,
    };
