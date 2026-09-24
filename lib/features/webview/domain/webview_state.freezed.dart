// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'webview_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ArticleMeta implements DiagnosticableTreeMixin {

 String get title; String get author; String get readTime; String get heroImageUrl;
/// Create a copy of ArticleMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArticleMetaCopyWith<ArticleMeta> get copyWith => _$ArticleMetaCopyWithImpl<ArticleMeta>(this as ArticleMeta, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  final _this = this as ArticleMeta;
  properties
    ..add(DiagnosticsProperty('type', 'ArticleMeta'))
    ..add(DiagnosticsProperty('title', _this.title))..add(DiagnosticsProperty('author', _this.author))..add(DiagnosticsProperty('readTime', _this.readTime))..add(DiagnosticsProperty('heroImageUrl', _this.heroImageUrl));
}

@override
bool operator ==(Object other) {
  final _this = this as ArticleMeta;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ArticleMeta&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.author, _this.author) || other.author == _this.author)&&(identical(other.readTime, _this.readTime) || other.readTime == _this.readTime)&&(identical(other.heroImageUrl, _this.heroImageUrl) || other.heroImageUrl == _this.heroImageUrl));
}


@override
int get hashCode {
  final _this = this as ArticleMeta;
  return Object.hash(runtimeType,_this.title,_this.author,_this.readTime,_this.heroImageUrl);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  final _this = this as ArticleMeta;
  return 'ArticleMeta(title: ${_this.title}, author: ${_this.author}, readTime: ${_this.readTime}, heroImageUrl: ${_this.heroImageUrl})';
}


}

/// @nodoc
abstract mixin class $ArticleMetaCopyWith<$Res>  {
  factory $ArticleMetaCopyWith(ArticleMeta value, $Res Function(ArticleMeta) _then) = _$ArticleMetaCopyWithImpl;
@useResult
$Res call({
 String title, String author, String readTime, String heroImageUrl
});




}
/// @nodoc
class _$ArticleMetaCopyWithImpl<$Res>
    implements $ArticleMetaCopyWith<$Res> {
  _$ArticleMetaCopyWithImpl(this._self, this._then);

  final ArticleMeta _self;
  final $Res Function(ArticleMeta) _then;

/// Create a copy of ArticleMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? author = null,Object? readTime = null,Object? heroImageUrl = null,}) {
  return _then(ArticleMeta(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,readTime: null == readTime ? _self.readTime : readTime // ignore: cast_nullable_to_non_nullable
as String,heroImageUrl: null == heroImageUrl ? _self.heroImageUrl : heroImageUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ArticleMeta].
extension ArticleMetaPatterns on ArticleMeta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ArticleMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ArticleMeta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ArticleMeta value)  $default,){
final _that = this;
switch (_that) {
case _ArticleMeta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ArticleMeta value)?  $default,){
final _that = this;
switch (_that) {
case _ArticleMeta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String author,  String readTime,  String heroImageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ArticleMeta() when $default != null:
return $default(_that.title,_that.author,_that.readTime,_that.heroImageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String author,  String readTime,  String heroImageUrl)  $default,) {final _that = this;
switch (_that) {
case _ArticleMeta():
return $default(_that.title,_that.author,_that.readTime,_that.heroImageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String author,  String readTime,  String heroImageUrl)?  $default,) {final _that = this;
switch (_that) {
case _ArticleMeta() when $default != null:
return $default(_that.title,_that.author,_that.readTime,_that.heroImageUrl);case _:
  return null;

}
}

}

/// @nodoc


class _ArticleMeta extends ArticleMeta with DiagnosticableTreeMixin {
  const _ArticleMeta({this.title = '', this.author = '', this.readTime = '', this.heroImageUrl = ''}): super._();
  

@override@JsonKey() final  String title;
@override@JsonKey() final  String author;
@override@JsonKey() final  String readTime;
@override@JsonKey() final  String heroImageUrl;

/// Create a copy of ArticleMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArticleMetaCopyWith<_ArticleMeta> get copyWith => __$ArticleMetaCopyWithImpl<_ArticleMeta>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'ArticleMeta'))
    ..add(DiagnosticsProperty('title', title))..add(DiagnosticsProperty('author', author))..add(DiagnosticsProperty('readTime', readTime))..add(DiagnosticsProperty('heroImageUrl', heroImageUrl));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ArticleMeta&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.readTime, readTime) || other.readTime == readTime)&&(identical(other.heroImageUrl, heroImageUrl) || other.heroImageUrl == heroImageUrl));
}


@override
int get hashCode {
    return Object.hash(runtimeType,title,author,readTime,heroImageUrl);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'ArticleMeta(title: $title, author: $author, readTime: $readTime, heroImageUrl: $heroImageUrl)';
}


}

/// @nodoc
abstract mixin class _$ArticleMetaCopyWith<$Res> implements $ArticleMetaCopyWith<$Res> {
  factory _$ArticleMetaCopyWith(_ArticleMeta value, $Res Function(_ArticleMeta) _then) = __$ArticleMetaCopyWithImpl;
@override @useResult
$Res call({
 String title, String author, String readTime, String heroImageUrl
});




}
/// @nodoc
class __$ArticleMetaCopyWithImpl<$Res>
    implements _$ArticleMetaCopyWith<$Res> {
  __$ArticleMetaCopyWithImpl(this._self, this._then);

  final _ArticleMeta _self;
  final $Res Function(_ArticleMeta) _then;

/// Create a copy of ArticleMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? author = null,Object? readTime = null,Object? heroImageUrl = null,}) {
  return _then(_ArticleMeta(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,readTime: null == readTime ? _self.readTime : readTime // ignore: cast_nullable_to_non_nullable
as String,heroImageUrl: null == heroImageUrl ? _self.heroImageUrl : heroImageUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
