enum GameTaste {
  liked,
  disliked;

  String get label => switch (this) {
    GameTaste.liked => 'Me gustó',
    GameTaste.disliked => 'No me gustó',
  };

  static GameTaste? tryParse(String? raw) {
    return GameTaste.values.asNameMap()[raw];
  }
}
