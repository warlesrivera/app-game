enum OwnershipFormat {
  physical,
  digital;

  String get label => switch (this) {
    OwnershipFormat.physical => 'Físico',
    OwnershipFormat.digital => 'Digital',
  };

  static OwnershipFormat? tryParse(String? raw) {
    return OwnershipFormat.values.asNameMap()[raw];
  }
}

enum OwnershipStore {
  playstation('PlayStation Store'),
  xbox('Xbox Store'),
  nintendo('Nintendo eShop'),
  steam('Steam'),
  epic('Epic Games'),
  gog('GOG'),
  amazon('Amazon'),
  other('Otra tienda');

  const OwnershipStore(this.label);

  final String label;

  bool get isFirstParty =>
      this == OwnershipStore.playstation ||
      this == OwnershipStore.xbox ||
      this == OwnershipStore.nintendo;

  static OwnershipStore? tryParse(String? raw) {
    return OwnershipStore.values.asNameMap()[raw];
  }
}
