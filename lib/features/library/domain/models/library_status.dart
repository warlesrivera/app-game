enum LibraryStatus {
  playing,
  completed,
  wishlist,
  abandoned;

  String get firestoreValue => name;

  String get label => switch (this) {
    LibraryStatus.playing => 'Jugando',
    LibraryStatus.completed => 'Completado',
    LibraryStatus.wishlist => 'Wishlist',
    LibraryStatus.abandoned => 'Abandonado',
  };

  static LibraryStatus? tryParse(String? raw) {
    return LibraryStatus.values.asNameMap()[raw];
  }
}

enum LibraryLayout { grid, list }

enum LibraryFilter {
  all,
  playing,
  completed,
  wishlist,
  abandoned;

  String get label => switch (this) {
    LibraryFilter.all => 'Todos',
    LibraryFilter.playing => 'Jugando',
    LibraryFilter.completed => 'Completados',
    LibraryFilter.wishlist => 'Wishlist',
    LibraryFilter.abandoned => 'Abandonados',
  };

  bool matches(LibraryStatus status) {
    return switch (this) {
      LibraryFilter.all => true,
      LibraryFilter.playing => status == LibraryStatus.playing,
      LibraryFilter.completed => status == LibraryStatus.completed,
      LibraryFilter.wishlist => status == LibraryStatus.wishlist,
      LibraryFilter.abandoned => status == LibraryStatus.abandoned,
    };
  }
}
