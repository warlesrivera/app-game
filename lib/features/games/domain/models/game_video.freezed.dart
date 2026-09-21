// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_video.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GameVideo {

 String get id; String get name; String get preview; String get url;
/// Create a copy of GameVideo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameVideoCopyWith<GameVideo> get copyWith => _$GameVideoCopyWithImpl<GameVideo>(this as GameVideo, _$identity);

  /// Serializes this GameVideo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameVideo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,preview,url);

@override
String toString() {
  return 'GameVideo(id: $id, name: $name, preview: $preview, url: $url)';
}


}

/// @nodoc
abstract mixin class $GameVideoCopyWith<$Res>  {
  factory $GameVideoCopyWith(GameVideo value, $Res Function(GameVideo) _then) = _$GameVideoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String preview, String url
});




}
/// @nodoc
class _$GameVideoCopyWithImpl<$Res>
    implements $GameVideoCopyWith<$Res> {
  _$GameVideoCopyWithImpl(this._self, this._then);

  final GameVideo _self;
  final $Res Function(GameVideo) _then;

/// Create a copy of GameVideo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? preview = null,Object? url = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,preview: null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GameVideo].
extension GameVideoPatterns on GameVideo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameVideo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameVideo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameVideo value)  $default,){
final _that = this;
switch (_that) {
case _GameVideo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameVideo value)?  $default,){
final _that = this;
switch (_that) {
case _GameVideo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String preview,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameVideo() when $default != null:
return $default(_that.id,_that.name,_that.preview,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String preview,  String url)  $default,) {final _that = this;
switch (_that) {
case _GameVideo():
return $default(_that.id,_that.name,_that.preview,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String preview,  String url)?  $default,) {final _that = this;
switch (_that) {
case _GameVideo() when $default != null:
return $default(_that.id,_that.name,_that.preview,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameVideo implements GameVideo {
  const _GameVideo({required this.id, required this.name, required this.preview, required this.url});
  factory _GameVideo.fromJson(Map<String, dynamic> json) => _$GameVideoFromJson(json);

@override final  String id;
@override final  String name;
@override final  String preview;
@override final  String url;

/// Create a copy of GameVideo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameVideoCopyWith<_GameVideo> get copyWith => __$GameVideoCopyWithImpl<_GameVideo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameVideoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameVideo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,preview,url);

@override
String toString() {
  return 'GameVideo(id: $id, name: $name, preview: $preview, url: $url)';
}


}

/// @nodoc
abstract mixin class _$GameVideoCopyWith<$Res> implements $GameVideoCopyWith<$Res> {
  factory _$GameVideoCopyWith(_GameVideo value, $Res Function(_GameVideo) _then) = __$GameVideoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String preview, String url
});




}
/// @nodoc
class __$GameVideoCopyWithImpl<$Res>
    implements _$GameVideoCopyWith<$Res> {
  __$GameVideoCopyWithImpl(this._self, this._then);

  final _GameVideo _self;
  final $Res Function(_GameVideo) _then;

/// Create a copy of GameVideo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? preview = null,Object? url = null,}) {
  return _then(_GameVideo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,preview: null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
