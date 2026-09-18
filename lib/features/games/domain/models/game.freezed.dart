// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Game {

 String get id; String get name; String? get description; DateTime? get releaseDate; String? get coverUrl; double? get rating; List<String> get platforms; List<String> get genres;
/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameCopyWith<Game> get copyWith => _$GameCopyWithImpl<Game>(this as Game, _$identity);

  /// Serializes this Game to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Game&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.rating, rating) || other.rating == rating)&&const DeepCollectionEquality().equals(other.platforms, platforms)&&const DeepCollectionEquality().equals(other.genres, genres));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,releaseDate,coverUrl,rating,const DeepCollectionEquality().hash(platforms),const DeepCollectionEquality().hash(genres));

@override
String toString() {
  return 'Game(id: $id, name: $name, description: $description, releaseDate: $releaseDate, coverUrl: $coverUrl, rating: $rating, platforms: $platforms, genres: $genres)';
}


}

/// @nodoc
abstract mixin class $GameCopyWith<$Res>  {
  factory $GameCopyWith(Game value, $Res Function(Game) _then) = _$GameCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, DateTime? releaseDate, String? coverUrl, double? rating, List<String> platforms, List<String> genres
});




}
/// @nodoc
class _$GameCopyWithImpl<$Res>
    implements $GameCopyWith<$Res> {
  _$GameCopyWithImpl(this._self, this._then);

  final Game _self;
  final $Res Function(Game) _then;

/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? releaseDate = freezed,Object? coverUrl = freezed,Object? rating = freezed,Object? platforms = null,Object? genres = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,platforms: null == platforms ? _self.platforms : platforms // ignore: cast_nullable_to_non_nullable
as List<String>,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Game].
extension GamePatterns on Game {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Game value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Game() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Game value)  $default,){
final _that = this;
switch (_that) {
case _Game():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Game value)?  $default,){
final _that = this;
switch (_that) {
case _Game() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  DateTime? releaseDate,  String? coverUrl,  double? rating,  List<String> platforms,  List<String> genres)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Game() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.releaseDate,_that.coverUrl,_that.rating,_that.platforms,_that.genres);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  DateTime? releaseDate,  String? coverUrl,  double? rating,  List<String> platforms,  List<String> genres)  $default,) {final _that = this;
switch (_that) {
case _Game():
return $default(_that.id,_that.name,_that.description,_that.releaseDate,_that.coverUrl,_that.rating,_that.platforms,_that.genres);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  DateTime? releaseDate,  String? coverUrl,  double? rating,  List<String> platforms,  List<String> genres)?  $default,) {final _that = this;
switch (_that) {
case _Game() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.releaseDate,_that.coverUrl,_that.rating,_that.platforms,_that.genres);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Game implements Game {
  const _Game({required this.id, required this.name, this.description, this.releaseDate, this.coverUrl, this.rating, final  List<String> platforms = const <String>[], final  List<String> genres = const <String>[]}): _platforms = platforms,_genres = genres;
  factory _Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override final  DateTime? releaseDate;
@override final  String? coverUrl;
@override final  double? rating;
 final  List<String> _platforms;
@override@JsonKey() List<String> get platforms {
  if (_platforms is EqualUnmodifiableListView) return _platforms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_platforms);
}

 final  List<String> _genres;
@override@JsonKey() List<String> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}


/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameCopyWith<_Game> get copyWith => __$GameCopyWithImpl<_Game>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Game&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.rating, rating) || other.rating == rating)&&const DeepCollectionEquality().equals(other._platforms, _platforms)&&const DeepCollectionEquality().equals(other._genres, _genres));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,releaseDate,coverUrl,rating,const DeepCollectionEquality().hash(_platforms),const DeepCollectionEquality().hash(_genres));

@override
String toString() {
  return 'Game(id: $id, name: $name, description: $description, releaseDate: $releaseDate, coverUrl: $coverUrl, rating: $rating, platforms: $platforms, genres: $genres)';
}


}

/// @nodoc
abstract mixin class _$GameCopyWith<$Res> implements $GameCopyWith<$Res> {
  factory _$GameCopyWith(_Game value, $Res Function(_Game) _then) = __$GameCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, DateTime? releaseDate, String? coverUrl, double? rating, List<String> platforms, List<String> genres
});




}
/// @nodoc
class __$GameCopyWithImpl<$Res>
    implements _$GameCopyWith<$Res> {
  __$GameCopyWithImpl(this._self, this._then);

  final _Game _self;
  final $Res Function(_Game) _then;

/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? releaseDate = freezed,Object? coverUrl = freezed,Object? rating = freezed,Object? platforms = null,Object? genres = null,}) {
  return _then(_Game(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,platforms: null == platforms ? _self._platforms : platforms // ignore: cast_nullable_to_non_nullable
as List<String>,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
