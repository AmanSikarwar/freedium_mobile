// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MirrorTestResult {

 bool get isReachable; int get responseTimeMs; int? get statusCode; String? get error;
/// Create a copy of MirrorTestResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MirrorTestResultCopyWith<MirrorTestResult> get copyWith => _$MirrorTestResultCopyWithImpl<MirrorTestResult>(this as MirrorTestResult, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MirrorTestResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MirrorTestResult&&(identical(other.isReachable, _this.isReachable) || other.isReachable == _this.isReachable)&&(identical(other.responseTimeMs, _this.responseTimeMs) || other.responseTimeMs == _this.responseTimeMs)&&(identical(other.statusCode, _this.statusCode) || other.statusCode == _this.statusCode)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as MirrorTestResult;
  return Object.hash(runtimeType,_this.isReachable,_this.responseTimeMs,_this.statusCode,_this.error);
}

@override
String toString() {
  final _this = this as MirrorTestResult;
  return 'MirrorTestResult(isReachable: ${_this.isReachable}, responseTimeMs: ${_this.responseTimeMs}, statusCode: ${_this.statusCode}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $MirrorTestResultCopyWith<$Res>  {
  factory $MirrorTestResultCopyWith(MirrorTestResult value, $Res Function(MirrorTestResult) _then) = _$MirrorTestResultCopyWithImpl;
@useResult
$Res call({
 bool isReachable, int responseTimeMs, int? statusCode, String? error
});




}
/// @nodoc
class _$MirrorTestResultCopyWithImpl<$Res>
    implements $MirrorTestResultCopyWith<$Res> {
  _$MirrorTestResultCopyWithImpl(this._self, this._then);

  final MirrorTestResult _self;
  final $Res Function(MirrorTestResult) _then;

/// Create a copy of MirrorTestResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isReachable = null,Object? responseTimeMs = null,Object? statusCode = freezed,Object? error = freezed,}) {
  return _then(MirrorTestResult(
isReachable: null == isReachable ? _self.isReachable : isReachable // ignore: cast_nullable_to_non_nullable
as bool,responseTimeMs: null == responseTimeMs ? _self.responseTimeMs : responseTimeMs // ignore: cast_nullable_to_non_nullable
as int,statusCode: freezed == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MirrorTestResult].
extension MirrorTestResultPatterns on MirrorTestResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MirrorTestResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MirrorTestResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MirrorTestResult value)  $default,){
final _that = this;
switch (_that) {
case _MirrorTestResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MirrorTestResult value)?  $default,){
final _that = this;
switch (_that) {
case _MirrorTestResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isReachable,  int responseTimeMs,  int? statusCode,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MirrorTestResult() when $default != null:
return $default(_that.isReachable,_that.responseTimeMs,_that.statusCode,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isReachable,  int responseTimeMs,  int? statusCode,  String? error)  $default,) {final _that = this;
switch (_that) {
case _MirrorTestResult():
return $default(_that.isReachable,_that.responseTimeMs,_that.statusCode,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isReachable,  int responseTimeMs,  int? statusCode,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _MirrorTestResult() when $default != null:
return $default(_that.isReachable,_that.responseTimeMs,_that.statusCode,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _MirrorTestResult implements MirrorTestResult {
  const _MirrorTestResult({required this.isReachable, required this.responseTimeMs, this.statusCode, this.error});
  

@override final  bool isReachable;
@override final  int responseTimeMs;
@override final  int? statusCode;
@override final  String? error;

/// Create a copy of MirrorTestResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MirrorTestResultCopyWith<_MirrorTestResult> get copyWith => __$MirrorTestResultCopyWithImpl<_MirrorTestResult>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MirrorTestResult&&(identical(other.isReachable, isReachable) || other.isReachable == isReachable)&&(identical(other.responseTimeMs, responseTimeMs) || other.responseTimeMs == responseTimeMs)&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,isReachable,responseTimeMs,statusCode,error);
}

@override
String toString() {
    return 'MirrorTestResult(isReachable: $isReachable, responseTimeMs: $responseTimeMs, statusCode: $statusCode, error: $error)';
}


}

/// @nodoc
abstract mixin class _$MirrorTestResultCopyWith<$Res> implements $MirrorTestResultCopyWith<$Res> {
  factory _$MirrorTestResultCopyWith(_MirrorTestResult value, $Res Function(_MirrorTestResult) _then) = __$MirrorTestResultCopyWithImpl;
@override @useResult
$Res call({
 bool isReachable, int responseTimeMs, int? statusCode, String? error
});




}
/// @nodoc
class __$MirrorTestResultCopyWithImpl<$Res>
    implements _$MirrorTestResultCopyWith<$Res> {
  __$MirrorTestResultCopyWithImpl(this._self, this._then);

  final _MirrorTestResult _self;
  final $Res Function(_MirrorTestResult) _then;

/// Create a copy of MirrorTestResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isReachable = null,Object? responseTimeMs = null,Object? statusCode = freezed,Object? error = freezed,}) {
  return _then(_MirrorTestResult(
isReachable: null == isReachable ? _self.isReachable : isReachable // ignore: cast_nullable_to_non_nullable
as bool,responseTimeMs: null == responseTimeMs ? _self.responseTimeMs : responseTimeMs // ignore: cast_nullable_to_non_nullable
as int,statusCode: freezed == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
