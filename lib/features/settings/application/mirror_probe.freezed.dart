// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mirror_probe.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MirrorProbeResult implements DiagnosticableTreeMixin {

 bool get isReachable; int? get statusCode; String? get error;
/// Create a copy of MirrorProbeResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MirrorProbeResultCopyWith<MirrorProbeResult> get copyWith => _$MirrorProbeResultCopyWithImpl<MirrorProbeResult>(this as MirrorProbeResult, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  final _this = this as MirrorProbeResult;
  properties
    ..add(DiagnosticsProperty('type', 'MirrorProbeResult'))
    ..add(DiagnosticsProperty('isReachable', _this.isReachable))..add(DiagnosticsProperty('statusCode', _this.statusCode))..add(DiagnosticsProperty('error', _this.error));
}

@override
bool operator ==(Object other) {
  final _this = this as MirrorProbeResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MirrorProbeResult&&(identical(other.isReachable, _this.isReachable) || other.isReachable == _this.isReachable)&&(identical(other.statusCode, _this.statusCode) || other.statusCode == _this.statusCode)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as MirrorProbeResult;
  return Object.hash(runtimeType,_this.isReachable,_this.statusCode,_this.error);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  final _this = this as MirrorProbeResult;
  return 'MirrorProbeResult(isReachable: ${_this.isReachable}, statusCode: ${_this.statusCode}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $MirrorProbeResultCopyWith<$Res>  {
  factory $MirrorProbeResultCopyWith(MirrorProbeResult value, $Res Function(MirrorProbeResult) _then) = _$MirrorProbeResultCopyWithImpl;
@useResult
$Res call({
 bool isReachable, int? statusCode, String? error
});




}
/// @nodoc
class _$MirrorProbeResultCopyWithImpl<$Res>
    implements $MirrorProbeResultCopyWith<$Res> {
  _$MirrorProbeResultCopyWithImpl(this._self, this._then);

  final MirrorProbeResult _self;
  final $Res Function(MirrorProbeResult) _then;

/// Create a copy of MirrorProbeResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isReachable = null,Object? statusCode = freezed,Object? error = freezed,}) {
  return _then(MirrorProbeResult(
isReachable: null == isReachable ? _self.isReachable : isReachable // ignore: cast_nullable_to_non_nullable
as bool,statusCode: freezed == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MirrorProbeResult].
extension MirrorProbeResultPatterns on MirrorProbeResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MirrorProbeResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MirrorProbeResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MirrorProbeResult value)  $default,){
final _that = this;
switch (_that) {
case _MirrorProbeResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MirrorProbeResult value)?  $default,){
final _that = this;
switch (_that) {
case _MirrorProbeResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isReachable,  int? statusCode,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MirrorProbeResult() when $default != null:
return $default(_that.isReachable,_that.statusCode,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isReachable,  int? statusCode,  String? error)  $default,) {final _that = this;
switch (_that) {
case _MirrorProbeResult():
return $default(_that.isReachable,_that.statusCode,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isReachable,  int? statusCode,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _MirrorProbeResult() when $default != null:
return $default(_that.isReachable,_that.statusCode,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _MirrorProbeResult with DiagnosticableTreeMixin implements MirrorProbeResult {
  const _MirrorProbeResult({required this.isReachable, this.statusCode, this.error});
  

@override final  bool isReachable;
@override final  int? statusCode;
@override final  String? error;

/// Create a copy of MirrorProbeResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MirrorProbeResultCopyWith<_MirrorProbeResult> get copyWith => __$MirrorProbeResultCopyWithImpl<_MirrorProbeResult>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'MirrorProbeResult'))
    ..add(DiagnosticsProperty('isReachable', isReachable))..add(DiagnosticsProperty('statusCode', statusCode))..add(DiagnosticsProperty('error', error));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MirrorProbeResult&&(identical(other.isReachable, isReachable) || other.isReachable == isReachable)&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,isReachable,statusCode,error);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'MirrorProbeResult(isReachable: $isReachable, statusCode: $statusCode, error: $error)';
}


}

/// @nodoc
abstract mixin class _$MirrorProbeResultCopyWith<$Res> implements $MirrorProbeResultCopyWith<$Res> {
  factory _$MirrorProbeResultCopyWith(_MirrorProbeResult value, $Res Function(_MirrorProbeResult) _then) = __$MirrorProbeResultCopyWithImpl;
@override @useResult
$Res call({
 bool isReachable, int? statusCode, String? error
});




}
/// @nodoc
class __$MirrorProbeResultCopyWithImpl<$Res>
    implements _$MirrorProbeResultCopyWith<$Res> {
  __$MirrorProbeResultCopyWithImpl(this._self, this._then);

  final _MirrorProbeResult _self;
  final $Res Function(_MirrorProbeResult) _then;

/// Create a copy of MirrorProbeResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isReachable = null,Object? statusCode = freezed,Object? error = freezed,}) {
  return _then(_MirrorProbeResult(
isReachable: null == isReachable ? _self.isReachable : isReachable // ignore: cast_nullable_to_non_nullable
as bool,statusCode: freezed == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
