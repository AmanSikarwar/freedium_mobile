// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bookmarked_article.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BookmarkedArticle {

 String get url; String get title;@JsonKey(fromJson: _savedAtFromJson, toJson: _savedAtToJson) DateTime get savedAt;
/// Create a copy of BookmarkedArticle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookmarkedArticleCopyWith<BookmarkedArticle> get copyWith => _$BookmarkedArticleCopyWithImpl<BookmarkedArticle>(this as BookmarkedArticle, _$identity);

  /// Serializes this BookmarkedArticle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BookmarkedArticle;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookmarkedArticle&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.savedAt, _this.savedAt) || other.savedAt == _this.savedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BookmarkedArticle;
  return Object.hash(runtimeType,_this.url,_this.title,_this.savedAt);
}

@override
String toString() {
  final _this = this as BookmarkedArticle;
  return 'BookmarkedArticle(url: ${_this.url}, title: ${_this.title}, savedAt: ${_this.savedAt})';
}


}

/// @nodoc
abstract mixin class $BookmarkedArticleCopyWith<$Res>  {
  factory $BookmarkedArticleCopyWith(BookmarkedArticle value, $Res Function(BookmarkedArticle) _then) = _$BookmarkedArticleCopyWithImpl;
@useResult
$Res call({
 String url, String title,@JsonKey(fromJson: _savedAtFromJson, toJson: _savedAtToJson) DateTime savedAt
});




}
/// @nodoc
class _$BookmarkedArticleCopyWithImpl<$Res>
    implements $BookmarkedArticleCopyWith<$Res> {
  _$BookmarkedArticleCopyWithImpl(this._self, this._then);

  final BookmarkedArticle _self;
  final $Res Function(BookmarkedArticle) _then;

/// Create a copy of BookmarkedArticle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? title = null,Object? savedAt = null,}) {
  return _then(BookmarkedArticle(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,savedAt: null == savedAt ? _self.savedAt : savedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [BookmarkedArticle].
extension BookmarkedArticlePatterns on BookmarkedArticle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookmarkedArticle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookmarkedArticle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookmarkedArticle value)  $default,){
final _that = this;
switch (_that) {
case _BookmarkedArticle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookmarkedArticle value)?  $default,){
final _that = this;
switch (_that) {
case _BookmarkedArticle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  String title, @JsonKey(fromJson: _savedAtFromJson, toJson: _savedAtToJson)  DateTime savedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookmarkedArticle() when $default != null:
return $default(_that.url,_that.title,_that.savedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  String title, @JsonKey(fromJson: _savedAtFromJson, toJson: _savedAtToJson)  DateTime savedAt)  $default,) {final _that = this;
switch (_that) {
case _BookmarkedArticle():
return $default(_that.url,_that.title,_that.savedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  String title, @JsonKey(fromJson: _savedAtFromJson, toJson: _savedAtToJson)  DateTime savedAt)?  $default,) {final _that = this;
switch (_that) {
case _BookmarkedArticle() when $default != null:
return $default(_that.url,_that.title,_that.savedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookmarkedArticle implements BookmarkedArticle {
  const _BookmarkedArticle({required this.url, this.title = '', @JsonKey(fromJson: _savedAtFromJson, toJson: _savedAtToJson) required this.savedAt});
  factory _BookmarkedArticle.fromJson(Map<String, dynamic> json) => _$BookmarkedArticleFromJson(json);

@override final  String url;
@override@JsonKey() final  String title;
@override@JsonKey(fromJson: _savedAtFromJson, toJson: _savedAtToJson) final  DateTime savedAt;

/// Create a copy of BookmarkedArticle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookmarkedArticleCopyWith<_BookmarkedArticle> get copyWith => __$BookmarkedArticleCopyWithImpl<_BookmarkedArticle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookmarkedArticleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookmarkedArticle&&(identical(other.url, url) || other.url == url)&&(identical(other.title, title) || other.title == title)&&(identical(other.savedAt, savedAt) || other.savedAt == savedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,url,title,savedAt);
}

@override
String toString() {
    return 'BookmarkedArticle(url: $url, title: $title, savedAt: $savedAt)';
}


}

/// @nodoc
abstract mixin class _$BookmarkedArticleCopyWith<$Res> implements $BookmarkedArticleCopyWith<$Res> {
  factory _$BookmarkedArticleCopyWith(_BookmarkedArticle value, $Res Function(_BookmarkedArticle) _then) = __$BookmarkedArticleCopyWithImpl;
@override @useResult
$Res call({
 String url, String title,@JsonKey(fromJson: _savedAtFromJson, toJson: _savedAtToJson) DateTime savedAt
});




}
/// @nodoc
class __$BookmarkedArticleCopyWithImpl<$Res>
    implements _$BookmarkedArticleCopyWith<$Res> {
  __$BookmarkedArticleCopyWithImpl(this._self, this._then);

  final _BookmarkedArticle _self;
  final $Res Function(_BookmarkedArticle) _then;

/// Create a copy of BookmarkedArticle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? title = null,Object? savedAt = null,}) {
  return _then(_BookmarkedArticle(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,savedAt: null == savedAt ? _self.savedAt : savedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
