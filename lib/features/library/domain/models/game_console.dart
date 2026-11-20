class GameConsole {
  const GameConsole({required this.slug, required this.label});

  final String slug;
  final String label;

  static const all = <GameConsole>[
    GameConsole(slug: 'pc', label: 'PC'),
    GameConsole(slug: 'playstation5', label: 'PlayStation 5'),
    GameConsole(slug: 'playstation4', label: 'PlayStation 4'),
    GameConsole(slug: 'playstation3', label: 'PlayStation 3'),
    GameConsole(slug: 'playstation2', label: 'PlayStation 2'),
    GameConsole(slug: 'playstation', label: 'PlayStation'),
    GameConsole(slug: 'psp', label: 'PSP'),
    GameConsole(slug: 'playstationvita', label: 'PS Vita'),
    GameConsole(slug: 'xbox-series-x', label: 'Xbox Series X/S'),
    GameConsole(slug: 'xbox-one', label: 'Xbox One'),
    GameConsole(slug: 'xbox', label: 'Xbox 360'),
    GameConsole(slug: 'nintendo-switch-2', label: 'Nintendo Switch 2'),
    GameConsole(slug: 'nintendo-switch', label: 'Nintendo Switch'),
    GameConsole(slug: 'nintendo-64', label: 'Nintendo 64'),
  ];

  static GameConsole? bySlug(String? slug) {
    if (slug == null || slug.isEmpty) {
      return null;
    }
    for (final console in all) {
      if (console.slug == slug) {
        return console;
      }
    }
    return null;
  }
}
