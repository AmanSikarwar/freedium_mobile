// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FreediumMirror {

 String get name; String get url; bool get isDefault; bool get isCustom;
/// Create a copy of FreediumMirror
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FreediumMirrorCopyWith<FreediumMirror> get copyWith => _$FreediumMirrorCopyWithImpl<FreediumMirror>(this as FreediumMirror, _$identity);

  /// Serializes this FreediumMirror to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FreediumMirror;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FreediumMirror&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.isDefault, _this.isDefault) || other.isDefault == _this.isDefault)&&(identical(other.isCustom, _this.isCustom) || other.isCustom == _this.isCustom));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FreediumMirror;
  return Object.hash(runtimeType,_this.name,_this.url,_this.isDefault,_this.isCustom);
}

@override
String toString() {
  final _this = this as FreediumMirror;
  return 'FreediumMirror(name: ${_this.name}, url: ${_this.url}, isDefault: ${_this.isDefault}, isCustom: ${_this.isCustom})';
}


}

/// @nodoc
abstract mixin class $FreediumMirrorCopyWith<$Res>  {
  factory $FreediumMirrorCopyWith(FreediumMirror value, $Res Function(FreediumMirror) _then) = _$FreediumMirrorCopyWithImpl;
@useResult
$Res call({
 String name, String url, bool isDefault, bool isCustom
});




}
/// @nodoc
class _$FreediumMirrorCopyWithImpl<$Res>
    implements $FreediumMirrorCopyWith<$Res> {
  _$FreediumMirrorCopyWithImpl(this._self, this._then);

  final FreediumMirror _self;
  final $Res Function(FreediumMirror) _then;

/// Create a copy of FreediumMirror
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? url = null,Object? isDefault = null,Object? isCustom = null,}) {
  return _then(FreediumMirror(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FreediumMirror].
extension FreediumMirrorPatterns on FreediumMirror {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FreediumMirror value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FreediumMirror() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FreediumMirror value)  $default,){
final _that = this;
switch (_that) {
case _FreediumMirror():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FreediumMirror value)?  $default,){
final _that = this;
switch (_that) {
case _FreediumMirror() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String url,  bool isDefault,  bool isCustom)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FreediumMirror() when $default != null:
return $default(_that.name,_that.url,_that.isDefault,_that.isCustom);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String url,  bool isDefault,  bool isCustom)  $default,) {final _that = this;
switch (_that) {
case _FreediumMirror():
return $default(_that.name,_that.url,_that.isDefault,_that.isCustom);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String url,  bool isDefault,  bool isCustom)?  $default,) {final _that = this;
switch (_that) {
case _FreediumMirror() when $default != null:
return $default(_that.name,_that.url,_that.isDefault,_that.isCustom);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FreediumMirror implements FreediumMirror {
  const _FreediumMirror({required this.name, required this.url, this.isDefault = false, this.isCustom = false});
  factory _FreediumMirror.fromJson(Map<String, dynamic> json) => _$FreediumMirrorFromJson(json);

@override final  String name;
@override final  String url;
@override@JsonKey() final  bool isDefault;
@override@JsonKey() final  bool isCustom;

/// Create a copy of FreediumMirror
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FreediumMirrorCopyWith<_FreediumMirror> get copyWith => __$FreediumMirrorCopyWithImpl<_FreediumMirror>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FreediumMirrorToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FreediumMirror&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.isCustom, isCustom) || other.isCustom == isCustom));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,url,isDefault,isCustom);
}

@override
String toString() {
    return 'FreediumMirror(name: $name, url: $url, isDefault: $isDefault, isCustom: $isCustom)';
}


}

/// @nodoc
abstract mixin class _$FreediumMirrorCopyWith<$Res> implements $FreediumMirrorCopyWith<$Res> {
  factory _$FreediumMirrorCopyWith(_FreediumMirror value, $Res Function(_FreediumMirror) _then) = __$FreediumMirrorCopyWithImpl;
@override @useResult
$Res call({
 String name, String url, bool isDefault, bool isCustom
});




}
/// @nodoc
class __$FreediumMirrorCopyWithImpl<$Res>
    implements _$FreediumMirrorCopyWith<$Res> {
  __$FreediumMirrorCopyWithImpl(this._self, this._then);

  final _FreediumMirror _self;
  final $Res Function(_FreediumMirror) _then;

/// Create a copy of FreediumMirror
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? url = null,Object? isDefault = null,Object? isCustom = null,}) {
  return _then(_FreediumMirror(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$SettingsState {

 ThemeMode get themeMode; double get defaultFontSize; List<FreediumMirror> get mirrors; String get selectedMirrorUrl; bool get autoSwitchMirror; int get mirrorTimeout; bool get showSitePopups;
/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsStateCopyWith<SettingsState> get copyWith => _$SettingsStateCopyWithImpl<SettingsState>(this as SettingsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SettingsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsState&&(identical(other.themeMode, _this.themeMode) || other.themeMode == _this.themeMode)&&(identical(other.defaultFontSize, _this.defaultFontSize) || other.defaultFontSize == _this.defaultFontSize)&&const DeepCollectionEquality().equals(other.mirrors, _this.mirrors)&&(identical(other.selectedMirrorUrl, _this.selectedMirrorUrl) || other.selectedMirrorUrl == _this.selectedMirrorUrl)&&(identical(other.autoSwitchMirror, _this.autoSwitchMirror) || other.autoSwitchMirror == _this.autoSwitchMirror)&&(identical(other.mirrorTimeout, _this.mirrorTimeout) || other.mirrorTimeout == _this.mirrorTimeout)&&(identical(other.showSitePopups, _this.showSitePopups) || other.showSitePopups == _this.showSitePopups));
}


@override
int get hashCode {
  final _this = this as SettingsState;
  return Object.hash(runtimeType,_this.themeMode,_this.defaultFontSize,const DeepCollectionEquality().hash(_this.mirrors),_this.selectedMirrorUrl,_this.autoSwitchMirror,_this.mirrorTimeout,_this.showSitePopups);
}

@override
String toString() {
  final _this = this as SettingsState;
  return 'SettingsState(themeMode: ${_this.themeMode}, defaultFontSize: ${_this.defaultFontSize}, mirrors: ${_this.mirrors}, selectedMirrorUrl: ${_this.selectedMirrorUrl}, autoSwitchMirror: ${_this.autoSwitchMirror}, mirrorTimeout: ${_this.mirrorTimeout}, showSitePopups: ${_this.showSitePopups})';
}


}

/// @nodoc
abstract mixin class $SettingsStateCopyWith<$Res>  {
  factory $SettingsStateCopyWith(SettingsState value, $Res Function(SettingsState) _then) = _$SettingsStateCopyWithImpl;
@useResult
$Res call({
 ThemeMode themeMode, double defaultFontSize, List<FreediumMirror> mirrors, String selectedMirrorUrl, bool autoSwitchMirror, int mirrorTimeout, bool showSitePopups
});




}
/// @nodoc
class _$SettingsStateCopyWithImpl<$Res>
    implements $SettingsStateCopyWith<$Res> {
  _$SettingsStateCopyWithImpl(this._self, this._then);

  final SettingsState _self;
  final $Res Function(SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? themeMode = null,Object? defaultFontSize = null,Object? mirrors = null,Object? selectedMirrorUrl = null,Object? autoSwitchMirror = null,Object? mirrorTimeout = null,Object? showSitePopups = null,}) {
  return _then(SettingsState(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,defaultFontSize: null == defaultFontSize ? _self.defaultFontSize : defaultFontSize // ignore: cast_nullable_to_non_nullable
as double,mirrors: null == mirrors ? _self.mirrors : mirrors // ignore: cast_nullable_to_non_nullable
as List<FreediumMirror>,selectedMirrorUrl: null == selectedMirrorUrl ? _self.selectedMirrorUrl : selectedMirrorUrl // ignore: cast_nullable_to_non_nullable
as String,autoSwitchMirror: null == autoSwitchMirror ? _self.autoSwitchMirror : autoSwitchMirror // ignore: cast_nullable_to_non_nullable
as bool,mirrorTimeout: null == mirrorTimeout ? _self.mirrorTimeout : mirrorTimeout // ignore: cast_nullable_to_non_nullable
as int,showSitePopups: null == showSitePopups ? _self.showSitePopups : showSitePopups // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SettingsState].
extension SettingsStatePatterns on SettingsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettingsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettingsState value)  $default,){
final _that = this;
switch (_that) {
case _SettingsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettingsState value)?  $default,){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ThemeMode themeMode,  double defaultFontSize,  List<FreediumMirror> mirrors,  String selectedMirrorUrl,  bool autoSwitchMirror,  int mirrorTimeout,  bool showSitePopups)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.themeMode,_that.defaultFontSize,_that.mirrors,_that.selectedMirrorUrl,_that.autoSwitchMirror,_that.mirrorTimeout,_that.showSitePopups);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ThemeMode themeMode,  double defaultFontSize,  List<FreediumMirror> mirrors,  String selectedMirrorUrl,  bool autoSwitchMirror,  int mirrorTimeout,  bool showSitePopups)  $default,) {final _that = this;
switch (_that) {
case _SettingsState():
return $default(_that.themeMode,_that.defaultFontSize,_that.mirrors,_that.selectedMirrorUrl,_that.autoSwitchMirror,_that.mirrorTimeout,_that.showSitePopups);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ThemeMode themeMode,  double defaultFontSize,  List<FreediumMirror> mirrors,  String selectedMirrorUrl,  bool autoSwitchMirror,  int mirrorTimeout,  bool showSitePopups)?  $default,) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.themeMode,_that.defaultFontSize,_that.mirrors,_that.selectedMirrorUrl,_that.autoSwitchMirror,_that.mirrorTimeout,_that.showSitePopups);case _:
  return null;

}
}

}

/// @nodoc


class _SettingsState extends SettingsState {
  const _SettingsState({this.themeMode = ThemeMode.system, this.defaultFontSize = SettingsState.defaultDefaultFontSize,  List<FreediumMirror> mirrors = const [], this.selectedMirrorUrl = AppConstants.freediumMirrorUrl, this.autoSwitchMirror = true, this.mirrorTimeout = SettingsState.defaultMirrorTimeout, this.showSitePopups = true}): _mirrors = mirrors,super._();
  

@override@JsonKey() final  ThemeMode themeMode;
@override@JsonKey() final  double defaultFontSize;
 final  List<FreediumMirror> _mirrors;
@override@JsonKey() List<FreediumMirror> get mirrors {
  if (_mirrors is EqualUnmodifiableListView) return _mirrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mirrors);
}

@override@JsonKey() final  String selectedMirrorUrl;
@override@JsonKey() final  bool autoSwitchMirror;
@override@JsonKey() final  int mirrorTimeout;
@override@JsonKey() final  bool showSitePopups;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsStateCopyWith<_SettingsState> get copyWith => __$SettingsStateCopyWithImpl<_SettingsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingsState&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.defaultFontSize, defaultFontSize) || other.defaultFontSize == defaultFontSize)&&const DeepCollectionEquality().equals(other.mirrors, _mirrors)&&(identical(other.selectedMirrorUrl, selectedMirrorUrl) || other.selectedMirrorUrl == selectedMirrorUrl)&&(identical(other.autoSwitchMirror, autoSwitchMirror) || other.autoSwitchMirror == autoSwitchMirror)&&(identical(other.mirrorTimeout, mirrorTimeout) || other.mirrorTimeout == mirrorTimeout)&&(identical(other.showSitePopups, showSitePopups) || other.showSitePopups == showSitePopups));
}


@override
int get hashCode {
    return Object.hash(runtimeType,themeMode,defaultFontSize,const DeepCollectionEquality().hash(_mirrors),selectedMirrorUrl,autoSwitchMirror,mirrorTimeout,showSitePopups);
}

@override
String toString() {
    return 'SettingsState(themeMode: $themeMode, defaultFontSize: $defaultFontSize, mirrors: $mirrors, selectedMirrorUrl: $selectedMirrorUrl, autoSwitchMirror: $autoSwitchMirror, mirrorTimeout: $mirrorTimeout, showSitePopups: $showSitePopups)';
}


}

/// @nodoc
abstract mixin class _$SettingsStateCopyWith<$Res> implements $SettingsStateCopyWith<$Res> {
  factory _$SettingsStateCopyWith(_SettingsState value, $Res Function(_SettingsState) _then) = __$SettingsStateCopyWithImpl;
@override @useResult
$Res call({
 ThemeMode themeMode, double defaultFontSize, List<FreediumMirror> mirrors, String selectedMirrorUrl, bool autoSwitchMirror, int mirrorTimeout, bool showSitePopups
});




}
/// @nodoc
class __$SettingsStateCopyWithImpl<$Res>
    implements _$SettingsStateCopyWith<$Res> {
  __$SettingsStateCopyWithImpl(this._self, this._then);

  final _SettingsState _self;
  final $Res Function(_SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? themeMode = null,Object? defaultFontSize = null,Object? mirrors = null,Object? selectedMirrorUrl = null,Object? autoSwitchMirror = null,Object? mirrorTimeout = null,Object? showSitePopups = null,}) {
  return _then(_SettingsState(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,defaultFontSize: null == defaultFontSize ? _self.defaultFontSize : defaultFontSize // ignore: cast_nullable_to_non_nullable
as double,mirrors: null == mirrors ? _self._mirrors : mirrors // ignore: cast_nullable_to_non_nullable
as List<FreediumMirror>,selectedMirrorUrl: null == selectedMirrorUrl ? _self.selectedMirrorUrl : selectedMirrorUrl // ignore: cast_nullable_to_non_nullable
as String,autoSwitchMirror: null == autoSwitchMirror ? _self.autoSwitchMirror : autoSwitchMirror // ignore: cast_nullable_to_non_nullable
as bool,mirrorTimeout: null == mirrorTimeout ? _self.mirrorTimeout : mirrorTimeout // ignore: cast_nullable_to_non_nullable
as int,showSitePopups: null == showSitePopups ? _self.showSitePopups : showSitePopups // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
