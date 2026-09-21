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

 String get id; String get name;@JsonKey(readValue: _readDescription) String? get description; DateTime? get releaseDate; String? get coverUrl; double? get rating; List<String> get platforms; List<String> get platformSlugs; List<String> get genres; List<String> get screenshotUrls; List<String> get developers; List<String> get publishers; List<String> get tags; List<String> get stores; bool get isDetailed; String? get website; int? get metacritic; int? get playtime; int? get ratingsCount; String? get esrbRating; String? get descriptionEs; String? get trailerUrl; String? get trailerPreviewUrl; String? get redditUrl;
/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameCopyWith<Game> get copyWith => _$GameCopyWithImpl<Game>(this as Game, _$identity);

  /// Serializes this Game to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Game&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.rating, rating) || other.rating == rating)&&const DeepCollectionEquality().equals(other.platforms, platforms)&&const DeepCollectionEquality().equals(other.platformSlugs, platformSlugs)&&const DeepCollectionEquality().equals(other.genres, genres)&&const DeepCollectionEquality().equals(other.screenshotUrls, screenshotUrls)&&const DeepCollectionEquality().equals(other.developers, developers)&&const DeepCollectionEquality().equals(other.publishers, publishers)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.stores, stores)&&(identical(other.isDetailed, isDetailed) || other.isDetailed == isDetailed)&&(identical(other.website, website) || other.website == website)&&(identical(other.metacritic, metacritic) || other.metacritic == metacritic)&&(identical(other.playtime, playtime) || other.playtime == playtime)&&(identical(other.ratingsCount, ratingsCount) || other.ratingsCount == ratingsCount)&&(identical(other.esrbRating, esrbRating) || other.esrbRating == esrbRating)&&(identical(other.descriptionEs, descriptionEs) || other.descriptionEs == descriptionEs)&&(identical(other.trailerUrl, trailerUrl) || other.trailerUrl == trailerUrl)&&(identical(other.trailerPreviewUrl, trailerPreviewUrl) || other.trailerPreviewUrl == trailerPreviewUrl)&&(identical(other.redditUrl, redditUrl) || other.redditUrl == redditUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,description,releaseDate,coverUrl,rating,const DeepCollectionEquality().hash(platforms),const DeepCollectionEquality().hash(platformSlugs),const DeepCollectionEquality().hash(genres),const DeepCollectionEquality().hash(screenshotUrls),const DeepCollectionEquality().hash(developers),const DeepCollectionEquality().hash(publishers),const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(stores),isDetailed,website,metacritic,playtime,ratingsCount,esrbRating,descriptionEs,trailerUrl,trailerPreviewUrl,redditUrl]);

@override
String toString() {
  return 'Game(id: $id, name: $name, description: $description, releaseDate: $releaseDate, coverUrl: $coverUrl, rating: $rating, platforms: $platforms, platformSlugs: $platformSlugs, genres: $genres, screenshotUrls: $screenshotUrls, developers: $developers, publishers: $publishers, tags: $tags, stores: $stores, isDetailed: $isDetailed, website: $website, metacritic: $metacritic, playtime: $playtime, ratingsCount: $ratingsCount, esrbRating: $esrbRating, descriptionEs: $descriptionEs, trailerUrl: $trailerUrl, trailerPreviewUrl: $trailerPreviewUrl, redditUrl: $redditUrl)';
}


}

/// @nodoc
abstract mixin class $GameCopyWith<$Res>  {
  factory $GameCopyWith(Game value, $Res Function(Game) _then) = _$GameCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(readValue: _readDescription) String? description, DateTime? releaseDate, String? coverUrl, double? rating, List<String> platforms, List<String> platformSlugs, List<String> genres, List<String> screenshotUrls, List<String> developers, List<String> publishers, List<String> tags, List<String> stores, bool isDetailed, String? website, int? metacritic, int? playtime, int? ratingsCount, String? esrbRating, String? descriptionEs, String? trailerUrl, String? trailerPreviewUrl, String? redditUrl
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? releaseDate = freezed,Object? coverUrl = freezed,Object? rating = freezed,Object? platforms = null,Object? platformSlugs = null,Object? genres = null,Object? screenshotUrls = null,Object? developers = null,Object? publishers = null,Object? tags = null,Object? stores = null,Object? isDetailed = null,Object? website = freezed,Object? metacritic = freezed,Object? playtime = freezed,Object? ratingsCount = freezed,Object? esrbRating = freezed,Object? descriptionEs = freezed,Object? trailerUrl = freezed,Object? trailerPreviewUrl = freezed,Object? redditUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,platforms: null == platforms ? _self.platforms : platforms // ignore: cast_nullable_to_non_nullable
as List<String>,platformSlugs: null == platformSlugs ? _self.platformSlugs : platformSlugs // ignore: cast_nullable_to_non_nullable
as List<String>,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,screenshotUrls: null == screenshotUrls ? _self.screenshotUrls : screenshotUrls // ignore: cast_nullable_to_non_nullable
as List<String>,developers: null == developers ? _self.developers : developers // ignore: cast_nullable_to_non_nullable
as List<String>,publishers: null == publishers ? _self.publishers : publishers // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,stores: null == stores ? _self.stores : stores // ignore: cast_nullable_to_non_nullable
as List<String>,isDetailed: null == isDetailed ? _self.isDetailed : isDetailed // ignore: cast_nullable_to_non_nullable
as bool,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,metacritic: freezed == metacritic ? _self.metacritic : metacritic // ignore: cast_nullable_to_non_nullable
as int?,playtime: freezed == playtime ? _self.playtime : playtime // ignore: cast_nullable_to_non_nullable
as int?,ratingsCount: freezed == ratingsCount ? _self.ratingsCount : ratingsCount // ignore: cast_nullable_to_non_nullable
as int?,esrbRating: freezed == esrbRating ? _self.esrbRating : esrbRating // ignore: cast_nullable_to_non_nullable
as String?,descriptionEs: freezed == descriptionEs ? _self.descriptionEs : descriptionEs // ignore: cast_nullable_to_non_nullable
as String?,trailerUrl: freezed == trailerUrl ? _self.trailerUrl : trailerUrl // ignore: cast_nullable_to_non_nullable
as String?,trailerPreviewUrl: freezed == trailerPreviewUrl ? _self.trailerPreviewUrl : trailerPreviewUrl // ignore: cast_nullable_to_non_nullable
as String?,redditUrl: freezed == redditUrl ? _self.redditUrl : redditUrl // ignore: cast_nullable_to_non_nullable
as String?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(readValue: _readDescription)  String? description,  DateTime? releaseDate,  String? coverUrl,  double? rating,  List<String> platforms,  List<String> platformSlugs,  List<String> genres,  List<String> screenshotUrls,  List<String> developers,  List<String> publishers,  List<String> tags,  List<String> stores,  bool isDetailed,  String? website,  int? metacritic,  int? playtime,  int? ratingsCount,  String? esrbRating,  String? descriptionEs,  String? trailerUrl,  String? trailerPreviewUrl,  String? redditUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Game() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.releaseDate,_that.coverUrl,_that.rating,_that.platforms,_that.platformSlugs,_that.genres,_that.screenshotUrls,_that.developers,_that.publishers,_that.tags,_that.stores,_that.isDetailed,_that.website,_that.metacritic,_that.playtime,_that.ratingsCount,_that.esrbRating,_that.descriptionEs,_that.trailerUrl,_that.trailerPreviewUrl,_that.redditUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(readValue: _readDescription)  String? description,  DateTime? releaseDate,  String? coverUrl,  double? rating,  List<String> platforms,  List<String> platformSlugs,  List<String> genres,  List<String> screenshotUrls,  List<String> developers,  List<String> publishers,  List<String> tags,  List<String> stores,  bool isDetailed,  String? website,  int? metacritic,  int? playtime,  int? ratingsCount,  String? esrbRating,  String? descriptionEs,  String? trailerUrl,  String? trailerPreviewUrl,  String? redditUrl)  $default,) {final _that = this;
switch (_that) {
case _Game():
return $default(_that.id,_that.name,_that.description,_that.releaseDate,_that.coverUrl,_that.rating,_that.platforms,_that.platformSlugs,_that.genres,_that.screenshotUrls,_that.developers,_that.publishers,_that.tags,_that.stores,_that.isDetailed,_that.website,_that.metacritic,_that.playtime,_that.ratingsCount,_that.esrbRating,_that.descriptionEs,_that.trailerUrl,_that.trailerPreviewUrl,_that.redditUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(readValue: _readDescription)  String? description,  DateTime? releaseDate,  String? coverUrl,  double? rating,  List<String> platforms,  List<String> platformSlugs,  List<String> genres,  List<String> screenshotUrls,  List<String> developers,  List<String> publishers,  List<String> tags,  List<String> stores,  bool isDetailed,  String? website,  int? metacritic,  int? playtime,  int? ratingsCount,  String? esrbRating,  String? descriptionEs,  String? trailerUrl,  String? trailerPreviewUrl,  String? redditUrl)?  $default,) {final _that = this;
switch (_that) {
case _Game() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.releaseDate,_that.coverUrl,_that.rating,_that.platforms,_that.platformSlugs,_that.genres,_that.screenshotUrls,_that.developers,_that.publishers,_that.tags,_that.stores,_that.isDetailed,_that.website,_that.metacritic,_that.playtime,_that.ratingsCount,_that.esrbRating,_that.descriptionEs,_that.trailerUrl,_that.trailerPreviewUrl,_that.redditUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Game implements Game {
  const _Game({required this.id, required this.name, @JsonKey(readValue: _readDescription) this.description, this.releaseDate, this.coverUrl, this.rating, final  List<String> platforms = const <String>[], final  List<String> platformSlugs = const <String>[], final  List<String> genres = const <String>[], final  List<String> screenshotUrls = const <String>[], final  List<String> developers = const <String>[], final  List<String> publishers = const <String>[], final  List<String> tags = const <String>[], final  List<String> stores = const <String>[], this.isDetailed = false, this.website, this.metacritic, this.playtime, this.ratingsCount, this.esrbRating, this.descriptionEs, this.trailerUrl, this.trailerPreviewUrl, this.redditUrl}): _platforms = platforms,_platformSlugs = platformSlugs,_genres = genres,_screenshotUrls = screenshotUrls,_developers = developers,_publishers = publishers,_tags = tags,_stores = stores;
  factory _Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(readValue: _readDescription) final  String? description;
@override final  DateTime? releaseDate;
@override final  String? coverUrl;
@override final  double? rating;
 final  List<String> _platforms;
@override@JsonKey() List<String> get platforms {
  if (_platforms is EqualUnmodifiableListView) return _platforms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_platforms);
}

 final  List<String> _platformSlugs;
@override@JsonKey() List<String> get platformSlugs {
  if (_platformSlugs is EqualUnmodifiableListView) return _platformSlugs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_platformSlugs);
}

 final  List<String> _genres;
@override@JsonKey() List<String> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

 final  List<String> _screenshotUrls;
@override@JsonKey() List<String> get screenshotUrls {
  if (_screenshotUrls is EqualUnmodifiableListView) return _screenshotUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_screenshotUrls);
}

 final  List<String> _developers;
@override@JsonKey() List<String> get developers {
  if (_developers is EqualUnmodifiableListView) return _developers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_developers);
}

 final  List<String> _publishers;
@override@JsonKey() List<String> get publishers {
  if (_publishers is EqualUnmodifiableListView) return _publishers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_publishers);
}

 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

 final  List<String> _stores;
@override@JsonKey() List<String> get stores {
  if (_stores is EqualUnmodifiableListView) return _stores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stores);
}

@override@JsonKey() final  bool isDetailed;
@override final  String? website;
@override final  int? metacritic;
@override final  int? playtime;
@override final  int? ratingsCount;
@override final  String? esrbRating;
@override final  String? descriptionEs;
@override final  String? trailerUrl;
@override final  String? trailerPreviewUrl;
@override final  String? redditUrl;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Game&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.rating, rating) || other.rating == rating)&&const DeepCollectionEquality().equals(other._platforms, _platforms)&&const DeepCollectionEquality().equals(other._platformSlugs, _platformSlugs)&&const DeepCollectionEquality().equals(other._genres, _genres)&&const DeepCollectionEquality().equals(other._screenshotUrls, _screenshotUrls)&&const DeepCollectionEquality().equals(other._developers, _developers)&&const DeepCollectionEquality().equals(other._publishers, _publishers)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._stores, _stores)&&(identical(other.isDetailed, isDetailed) || other.isDetailed == isDetailed)&&(identical(other.website, website) || other.website == website)&&(identical(other.metacritic, metacritic) || other.metacritic == metacritic)&&(identical(other.playtime, playtime) || other.playtime == playtime)&&(identical(other.ratingsCount, ratingsCount) || other.ratingsCount == ratingsCount)&&(identical(other.esrbRating, esrbRating) || other.esrbRating == esrbRating)&&(identical(other.descriptionEs, descriptionEs) || other.descriptionEs == descriptionEs)&&(identical(other.trailerUrl, trailerUrl) || other.trailerUrl == trailerUrl)&&(identical(other.trailerPreviewUrl, trailerPreviewUrl) || other.trailerPreviewUrl == trailerPreviewUrl)&&(identical(other.redditUrl, redditUrl) || other.redditUrl == redditUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,description,releaseDate,coverUrl,rating,const DeepCollectionEquality().hash(_platforms),const DeepCollectionEquality().hash(_platformSlugs),const DeepCollectionEquality().hash(_genres),const DeepCollectionEquality().hash(_screenshotUrls),const DeepCollectionEquality().hash(_developers),const DeepCollectionEquality().hash(_publishers),const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_stores),isDetailed,website,metacritic,playtime,ratingsCount,esrbRating,descriptionEs,trailerUrl,trailerPreviewUrl,redditUrl]);

@override
String toString() {
  return 'Game(id: $id, name: $name, description: $description, releaseDate: $releaseDate, coverUrl: $coverUrl, rating: $rating, platforms: $platforms, platformSlugs: $platformSlugs, genres: $genres, screenshotUrls: $screenshotUrls, developers: $developers, publishers: $publishers, tags: $tags, stores: $stores, isDetailed: $isDetailed, website: $website, metacritic: $metacritic, playtime: $playtime, ratingsCount: $ratingsCount, esrbRating: $esrbRating, descriptionEs: $descriptionEs, trailerUrl: $trailerUrl, trailerPreviewUrl: $trailerPreviewUrl, redditUrl: $redditUrl)';
}


}

/// @nodoc
abstract mixin class _$GameCopyWith<$Res> implements $GameCopyWith<$Res> {
  factory _$GameCopyWith(_Game value, $Res Function(_Game) _then) = __$GameCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(readValue: _readDescription) String? description, DateTime? releaseDate, String? coverUrl, double? rating, List<String> platforms, List<String> platformSlugs, List<String> genres, List<String> screenshotUrls, List<String> developers, List<String> publishers, List<String> tags, List<String> stores, bool isDetailed, String? website, int? metacritic, int? playtime, int? ratingsCount, String? esrbRating, String? descriptionEs, String? trailerUrl, String? trailerPreviewUrl, String? redditUrl
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? releaseDate = freezed,Object? coverUrl = freezed,Object? rating = freezed,Object? platforms = null,Object? platformSlugs = null,Object? genres = null,Object? screenshotUrls = null,Object? developers = null,Object? publishers = null,Object? tags = null,Object? stores = null,Object? isDetailed = null,Object? website = freezed,Object? metacritic = freezed,Object? playtime = freezed,Object? ratingsCount = freezed,Object? esrbRating = freezed,Object? descriptionEs = freezed,Object? trailerUrl = freezed,Object? trailerPreviewUrl = freezed,Object? redditUrl = freezed,}) {
  return _then(_Game(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,platforms: null == platforms ? _self._platforms : platforms // ignore: cast_nullable_to_non_nullable
as List<String>,platformSlugs: null == platformSlugs ? _self._platformSlugs : platformSlugs // ignore: cast_nullable_to_non_nullable
as List<String>,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,screenshotUrls: null == screenshotUrls ? _self._screenshotUrls : screenshotUrls // ignore: cast_nullable_to_non_nullable
as List<String>,developers: null == developers ? _self._developers : developers // ignore: cast_nullable_to_non_nullable
as List<String>,publishers: null == publishers ? _self._publishers : publishers // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,stores: null == stores ? _self._stores : stores // ignore: cast_nullable_to_non_nullable
as List<String>,isDetailed: null == isDetailed ? _self.isDetailed : isDetailed // ignore: cast_nullable_to_non_nullable
as bool,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,metacritic: freezed == metacritic ? _self.metacritic : metacritic // ignore: cast_nullable_to_non_nullable
as int?,playtime: freezed == playtime ? _self.playtime : playtime // ignore: cast_nullable_to_non_nullable
as int?,ratingsCount: freezed == ratingsCount ? _self.ratingsCount : ratingsCount // ignore: cast_nullable_to_non_nullable
as int?,esrbRating: freezed == esrbRating ? _self.esrbRating : esrbRating // ignore: cast_nullable_to_non_nullable
as String?,descriptionEs: freezed == descriptionEs ? _self.descriptionEs : descriptionEs // ignore: cast_nullable_to_non_nullable
as String?,trailerUrl: freezed == trailerUrl ? _self.trailerUrl : trailerUrl // ignore: cast_nullable_to_non_nullable
as String?,trailerPreviewUrl: freezed == trailerPreviewUrl ? _self.trailerPreviewUrl : trailerPreviewUrl // ignore: cast_nullable_to_non_nullable
as String?,redditUrl: freezed == redditUrl ? _self.redditUrl : redditUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
