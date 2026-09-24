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
mixin _$ArticleMeta {

 String get title; String get author; String get readTime; String get heroImageUrl;
/// Create a copy of ArticleMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArticleMetaCopyWith<ArticleMeta> get copyWith => _$ArticleMetaCopyWithImpl<ArticleMeta>(this as ArticleMeta, _$identity);



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
String toString() {
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


class _ArticleMeta extends ArticleMeta {
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
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ArticleMeta&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.readTime, readTime) || other.readTime == readTime)&&(identical(other.heroImageUrl, heroImageUrl) || other.heroImageUrl == heroImageUrl));
}


@override
int get hashCode {
    return Object.hash(runtimeType,title,author,readTime,heroImageUrl);
}

@override
String toString() {
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

/// @nodoc
mixin _$WebviewState {

 double get progress; bool get isPageLoaded; bool get isThemeApplied; bool get isInitialLoad; double get fontSize; String? get currentUrl; String get activeBaseUrl; bool get hasError; String? get errorMessage; String? get userMessage; ArticleMeta? get articleMeta;
/// Create a copy of WebviewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WebviewStateCopyWith<WebviewState> get copyWith => _$WebviewStateCopyWithImpl<WebviewState>(this as WebviewState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WebviewState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WebviewState&&(identical(other.progress, _this.progress) || other.progress == _this.progress)&&(identical(other.isPageLoaded, _this.isPageLoaded) || other.isPageLoaded == _this.isPageLoaded)&&(identical(other.isThemeApplied, _this.isThemeApplied) || other.isThemeApplied == _this.isThemeApplied)&&(identical(other.isInitialLoad, _this.isInitialLoad) || other.isInitialLoad == _this.isInitialLoad)&&(identical(other.fontSize, _this.fontSize) || other.fontSize == _this.fontSize)&&(identical(other.currentUrl, _this.currentUrl) || other.currentUrl == _this.currentUrl)&&(identical(other.activeBaseUrl, _this.activeBaseUrl) || other.activeBaseUrl == _this.activeBaseUrl)&&(identical(other.hasError, _this.hasError) || other.hasError == _this.hasError)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage)&&(identical(other.userMessage, _this.userMessage) || other.userMessage == _this.userMessage)&&(identical(other.articleMeta, _this.articleMeta) || other.articleMeta == _this.articleMeta));
}


@override
int get hashCode {
  final _this = this as WebviewState;
  return Object.hash(runtimeType,_this.progress,_this.isPageLoaded,_this.isThemeApplied,_this.isInitialLoad,_this.fontSize,_this.currentUrl,_this.activeBaseUrl,_this.hasError,_this.errorMessage,_this.userMessage,_this.articleMeta);
}

@override
String toString() {
  final _this = this as WebviewState;
  return 'WebviewState(progress: ${_this.progress}, isPageLoaded: ${_this.isPageLoaded}, isThemeApplied: ${_this.isThemeApplied}, isInitialLoad: ${_this.isInitialLoad}, fontSize: ${_this.fontSize}, currentUrl: ${_this.currentUrl}, activeBaseUrl: ${_this.activeBaseUrl}, hasError: ${_this.hasError}, errorMessage: ${_this.errorMessage}, userMessage: ${_this.userMessage}, articleMeta: ${_this.articleMeta})';
}


}

/// @nodoc
abstract mixin class $WebviewStateCopyWith<$Res>  {
  factory $WebviewStateCopyWith(WebviewState value, $Res Function(WebviewState) _then) = _$WebviewStateCopyWithImpl;
@useResult
$Res call({
 double progress, bool isPageLoaded, bool isThemeApplied, bool isInitialLoad, double fontSize, String? currentUrl, String activeBaseUrl, bool hasError, String? errorMessage, String? userMessage, ArticleMeta? articleMeta
});


$ArticleMetaCopyWith<$Res>? get articleMeta;

}
/// @nodoc
class _$WebviewStateCopyWithImpl<$Res>
    implements $WebviewStateCopyWith<$Res> {
  _$WebviewStateCopyWithImpl(this._self, this._then);

  final WebviewState _self;
  final $Res Function(WebviewState) _then;

/// Create a copy of WebviewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? progress = null,Object? isPageLoaded = null,Object? isThemeApplied = null,Object? isInitialLoad = null,Object? fontSize = null,Object? currentUrl = freezed,Object? activeBaseUrl = null,Object? hasError = null,Object? errorMessage = freezed,Object? userMessage = freezed,Object? articleMeta = freezed,}) {
  return _then(WebviewState(
progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,isPageLoaded: null == isPageLoaded ? _self.isPageLoaded : isPageLoaded // ignore: cast_nullable_to_non_nullable
as bool,isThemeApplied: null == isThemeApplied ? _self.isThemeApplied : isThemeApplied // ignore: cast_nullable_to_non_nullable
as bool,isInitialLoad: null == isInitialLoad ? _self.isInitialLoad : isInitialLoad // ignore: cast_nullable_to_non_nullable
as bool,fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as double,currentUrl: freezed == currentUrl ? _self.currentUrl : currentUrl // ignore: cast_nullable_to_non_nullable
as String?,activeBaseUrl: null == activeBaseUrl ? _self.activeBaseUrl : activeBaseUrl // ignore: cast_nullable_to_non_nullable
as String,hasError: null == hasError ? _self.hasError : hasError // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,userMessage: freezed == userMessage ? _self.userMessage : userMessage // ignore: cast_nullable_to_non_nullable
as String?,articleMeta: freezed == articleMeta ? _self.articleMeta : articleMeta // ignore: cast_nullable_to_non_nullable
as ArticleMeta?,
  ));
}
/// Create a copy of WebviewState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ArticleMetaCopyWith<$Res>? get articleMeta {
    if (_self.articleMeta == null) {
    return null;
  }

  return $ArticleMetaCopyWith<$Res>(_self.articleMeta!, (value) {
    return _then(_self.copyWith(articleMeta: value));
  });
}
}


/// Adds pattern-matching-related methods to [WebviewState].
extension WebviewStatePatterns on WebviewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WebviewState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WebviewState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WebviewState value)  $default,){
final _that = this;
switch (_that) {
case _WebviewState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WebviewState value)?  $default,){
final _that = this;
switch (_that) {
case _WebviewState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double progress,  bool isPageLoaded,  bool isThemeApplied,  bool isInitialLoad,  double fontSize,  String? currentUrl,  String activeBaseUrl,  bool hasError,  String? errorMessage,  String? userMessage,  ArticleMeta? articleMeta)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WebviewState() when $default != null:
return $default(_that.progress,_that.isPageLoaded,_that.isThemeApplied,_that.isInitialLoad,_that.fontSize,_that.currentUrl,_that.activeBaseUrl,_that.hasError,_that.errorMessage,_that.userMessage,_that.articleMeta);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double progress,  bool isPageLoaded,  bool isThemeApplied,  bool isInitialLoad,  double fontSize,  String? currentUrl,  String activeBaseUrl,  bool hasError,  String? errorMessage,  String? userMessage,  ArticleMeta? articleMeta)  $default,) {final _that = this;
switch (_that) {
case _WebviewState():
return $default(_that.progress,_that.isPageLoaded,_that.isThemeApplied,_that.isInitialLoad,_that.fontSize,_that.currentUrl,_that.activeBaseUrl,_that.hasError,_that.errorMessage,_that.userMessage,_that.articleMeta);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double progress,  bool isPageLoaded,  bool isThemeApplied,  bool isInitialLoad,  double fontSize,  String? currentUrl,  String activeBaseUrl,  bool hasError,  String? errorMessage,  String? userMessage,  ArticleMeta? articleMeta)?  $default,) {final _that = this;
switch (_that) {
case _WebviewState() when $default != null:
return $default(_that.progress,_that.isPageLoaded,_that.isThemeApplied,_that.isInitialLoad,_that.fontSize,_that.currentUrl,_that.activeBaseUrl,_that.hasError,_that.errorMessage,_that.userMessage,_that.articleMeta);case _:
  return null;

}
}

}

/// @nodoc


class _WebviewState extends WebviewState {
  const _WebviewState({this.progress = 0.0, this.isPageLoaded = false, this.isThemeApplied = false, this.isInitialLoad = true, this.fontSize = 18.0, this.currentUrl, this.activeBaseUrl = AppConstants.freediumUrl, this.hasError = false, this.errorMessage, this.userMessage, this.articleMeta}): super._();
  

@override@JsonKey() final  double progress;
@override@JsonKey() final  bool isPageLoaded;
@override@JsonKey() final  bool isThemeApplied;
@override@JsonKey() final  bool isInitialLoad;
@override@JsonKey() final  double fontSize;
@override final  String? currentUrl;
@override@JsonKey() final  String activeBaseUrl;
@override@JsonKey() final  bool hasError;
@override final  String? errorMessage;
@override final  String? userMessage;
@override final  ArticleMeta? articleMeta;

/// Create a copy of WebviewState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WebviewStateCopyWith<_WebviewState> get copyWith => __$WebviewStateCopyWithImpl<_WebviewState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WebviewState&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.isPageLoaded, isPageLoaded) || other.isPageLoaded == isPageLoaded)&&(identical(other.isThemeApplied, isThemeApplied) || other.isThemeApplied == isThemeApplied)&&(identical(other.isInitialLoad, isInitialLoad) || other.isInitialLoad == isInitialLoad)&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.currentUrl, currentUrl) || other.currentUrl == currentUrl)&&(identical(other.activeBaseUrl, activeBaseUrl) || other.activeBaseUrl == activeBaseUrl)&&(identical(other.hasError, hasError) || other.hasError == hasError)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.userMessage, userMessage) || other.userMessage == userMessage)&&(identical(other.articleMeta, articleMeta) || other.articleMeta == articleMeta));
}


@override
int get hashCode {
    return Object.hash(runtimeType,progress,isPageLoaded,isThemeApplied,isInitialLoad,fontSize,currentUrl,activeBaseUrl,hasError,errorMessage,userMessage,articleMeta);
}

@override
String toString() {
    return 'WebviewState(progress: $progress, isPageLoaded: $isPageLoaded, isThemeApplied: $isThemeApplied, isInitialLoad: $isInitialLoad, fontSize: $fontSize, currentUrl: $currentUrl, activeBaseUrl: $activeBaseUrl, hasError: $hasError, errorMessage: $errorMessage, userMessage: $userMessage, articleMeta: $articleMeta)';
}


}

/// @nodoc
abstract mixin class _$WebviewStateCopyWith<$Res> implements $WebviewStateCopyWith<$Res> {
  factory _$WebviewStateCopyWith(_WebviewState value, $Res Function(_WebviewState) _then) = __$WebviewStateCopyWithImpl;
@override @useResult
$Res call({
 double progress, bool isPageLoaded, bool isThemeApplied, bool isInitialLoad, double fontSize, String? currentUrl, String activeBaseUrl, bool hasError, String? errorMessage, String? userMessage, ArticleMeta? articleMeta
});


@override $ArticleMetaCopyWith<$Res>? get articleMeta;

}
/// @nodoc
class __$WebviewStateCopyWithImpl<$Res>
    implements _$WebviewStateCopyWith<$Res> {
  __$WebviewStateCopyWithImpl(this._self, this._then);

  final _WebviewState _self;
  final $Res Function(_WebviewState) _then;

/// Create a copy of WebviewState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? progress = null,Object? isPageLoaded = null,Object? isThemeApplied = null,Object? isInitialLoad = null,Object? fontSize = null,Object? currentUrl = freezed,Object? activeBaseUrl = null,Object? hasError = null,Object? errorMessage = freezed,Object? userMessage = freezed,Object? articleMeta = freezed,}) {
  return _then(_WebviewState(
progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,isPageLoaded: null == isPageLoaded ? _self.isPageLoaded : isPageLoaded // ignore: cast_nullable_to_non_nullable
as bool,isThemeApplied: null == isThemeApplied ? _self.isThemeApplied : isThemeApplied // ignore: cast_nullable_to_non_nullable
as bool,isInitialLoad: null == isInitialLoad ? _self.isInitialLoad : isInitialLoad // ignore: cast_nullable_to_non_nullable
as bool,fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as double,currentUrl: freezed == currentUrl ? _self.currentUrl : currentUrl // ignore: cast_nullable_to_non_nullable
as String?,activeBaseUrl: null == activeBaseUrl ? _self.activeBaseUrl : activeBaseUrl // ignore: cast_nullable_to_non_nullable
as String,hasError: null == hasError ? _self.hasError : hasError // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,userMessage: freezed == userMessage ? _self.userMessage : userMessage // ignore: cast_nullable_to_non_nullable
as String?,articleMeta: freezed == articleMeta ? _self.articleMeta : articleMeta // ignore: cast_nullable_to_non_nullable
as ArticleMeta?,
  ));
}

/// Create a copy of WebviewState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ArticleMetaCopyWith<$Res>? get articleMeta {
    if (_self.articleMeta == null) {
    return null;
  }

  return $ArticleMetaCopyWith<$Res>(_self.articleMeta!, (value) {
    return _then(_self.copyWith(articleMeta: value));
  });
}
}

// dart format on
