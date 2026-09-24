// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reading_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReadingHistory {

 String get url; String get title;@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime get timestamp;@JsonKey(fromJson: _progressFromJson) double get progress;
/// Create a copy of ReadingHistory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadingHistoryCopyWith<ReadingHistory> get copyWith => _$ReadingHistoryCopyWithImpl<ReadingHistory>(this as ReadingHistory, _$identity);

  /// Serializes this ReadingHistory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReadingHistory;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadingHistory&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.timestamp, _this.timestamp) || other.timestamp == _this.timestamp)&&(identical(other.progress, _this.progress) || other.progress == _this.progress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReadingHistory;
  return Object.hash(runtimeType,_this.url,_this.title,_this.timestamp,_this.progress);
}

@override
String toString() {
  final _this = this as ReadingHistory;
  return 'ReadingHistory(url: ${_this.url}, title: ${_this.title}, timestamp: ${_this.timestamp}, progress: ${_this.progress})';
}


}

/// @nodoc
abstract mixin class $ReadingHistoryCopyWith<$Res>  {
  factory $ReadingHistoryCopyWith(ReadingHistory value, $Res Function(ReadingHistory) _then) = _$ReadingHistoryCopyWithImpl;
@useResult
$Res call({
 String url, String title,@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime timestamp,@JsonKey(fromJson: _progressFromJson) double progress
});




}
/// @nodoc
class _$ReadingHistoryCopyWithImpl<$Res>
    implements $ReadingHistoryCopyWith<$Res> {
  _$ReadingHistoryCopyWithImpl(this._self, this._then);

  final ReadingHistory _self;
  final $Res Function(ReadingHistory) _then;

/// Create a copy of ReadingHistory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? title = null,Object? timestamp = null,Object? progress = null,}) {
  return _then(ReadingHistory(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ReadingHistory].
extension ReadingHistoryPatterns on ReadingHistory {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReadingHistory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReadingHistory() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReadingHistory value)  $default,){
final _that = this;
switch (_that) {
case _ReadingHistory():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReadingHistory value)?  $default,){
final _that = this;
switch (_that) {
case _ReadingHistory() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  String title, @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime timestamp, @JsonKey(fromJson: _progressFromJson)  double progress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReadingHistory() when $default != null:
return $default(_that.url,_that.title,_that.timestamp,_that.progress);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  String title, @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime timestamp, @JsonKey(fromJson: _progressFromJson)  double progress)  $default,) {final _that = this;
switch (_that) {
case _ReadingHistory():
return $default(_that.url,_that.title,_that.timestamp,_that.progress);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  String title, @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime timestamp, @JsonKey(fromJson: _progressFromJson)  double progress)?  $default,) {final _that = this;
switch (_that) {
case _ReadingHistory() when $default != null:
return $default(_that.url,_that.title,_that.timestamp,_that.progress);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReadingHistory extends ReadingHistory {
  const _ReadingHistory({required this.url, this.title = '', @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) required this.timestamp, @JsonKey(fromJson: _progressFromJson) this.progress = 0}): super._();
  factory _ReadingHistory.fromJson(Map<String, dynamic> json) => _$ReadingHistoryFromJson(json);

@override final  String url;
@override@JsonKey() final  String title;
@override@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) final  DateTime timestamp;
@override@JsonKey(fromJson: _progressFromJson) final  double progress;

/// Create a copy of ReadingHistory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadingHistoryCopyWith<_ReadingHistory> get copyWith => __$ReadingHistoryCopyWithImpl<_ReadingHistory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReadingHistoryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReadingHistory&&(identical(other.url, url) || other.url == url)&&(identical(other.title, title) || other.title == title)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.progress, progress) || other.progress == progress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,url,title,timestamp,progress);
}

@override
String toString() {
    return 'ReadingHistory(url: $url, title: $title, timestamp: $timestamp, progress: $progress)';
}


}

/// @nodoc
abstract mixin class _$ReadingHistoryCopyWith<$Res> implements $ReadingHistoryCopyWith<$Res> {
  factory _$ReadingHistoryCopyWith(_ReadingHistory value, $Res Function(_ReadingHistory) _then) = __$ReadingHistoryCopyWithImpl;
@override @useResult
$Res call({
 String url, String title,@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime timestamp,@JsonKey(fromJson: _progressFromJson) double progress
});




}
/// @nodoc
class __$ReadingHistoryCopyWithImpl<$Res>
    implements _$ReadingHistoryCopyWith<$Res> {
  __$ReadingHistoryCopyWithImpl(this._self, this._then);

  final _ReadingHistory _self;
  final $Res Function(_ReadingHistory) _then;

/// Create a copy of ReadingHistory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? title = null,Object? timestamp = null,Object? progress = null,}) {
  return _then(_ReadingHistory(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
