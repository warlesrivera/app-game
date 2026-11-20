class PlatformSearch {
  const PlatformSearch({
    required this.label,
    this.platforms,
    this.parentPlatform,
    this.dates,
    this.text,
  });

  final String label;
  final String? platforms;
  final int? parentPlatform;
  final String? dates;
  final String? text;

  bool get isCatalog => text == null || text!.isEmpty;

  static PlatformSearch? resolve(String raw) {
    final tokens = _tokens(raw);
    if (tokens.isEmpty) {
      return null;
    }

    final exact = _aliasByKey[tokens.join(' ')];
    if (exact != null) {
      return exact.toSearch();
    }

    for (final alias in _aliases) {
      if (alias.tokens.length >= tokens.length) {
        continue;
      }
      final asPrefix = _startsWith(tokens, alias.tokens);
      final prefixAllowed =
          asPrefix &&
          (alias.tokens.length > 1 || !_blockedPrefixes.contains(alias.phrase));
      if (prefixAllowed) {
        return alias.toSearch(
          text: tokens.sublist(alias.tokens.length).join(' '),
        );
      }
      if (_endsWith(tokens, alias.tokens)) {
        return alias.toSearch(
          text: tokens.sublist(0, tokens.length - alias.tokens.length).join(' '),
        );
      }
    }
    return null;
  }

  static List<String> _tokens(String raw) {
    final folded = _fold(raw);
    final cleaned = folded.replaceAll(RegExp('[^a-z0-9]+'), ' ').trim();
    if (cleaned.isEmpty) {
      return const [];
    }
    return cleaned.split(RegExp(r'\s+'));
  }

  static String _fold(String input) {
    const accents = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ü': 'u',
      'ñ': 'n',
    };
    final buffer = StringBuffer();
    for (final char in input.toLowerCase().split('')) {
      buffer.write(accents[char] ?? char);
    }
    return buffer.toString();
  }

  static const _blockedPrefixes = {'pc', 'ps', 'steam'};

  static bool _startsWith(List<String> tokens, List<String> alias) {
    for (var i = 0; i < alias.length; i++) {
      if (tokens[i] != alias[i]) {
        return false;
      }
    }
    return true;
  }

  static bool _endsWith(List<String> tokens, List<String> alias) {
    final offset = tokens.length - alias.length;
    for (var i = 0; i < alias.length; i++) {
      if (tokens[offset + i] != alias[i]) {
        return false;
      }
    }
    return true;
  }
}

class _Alias {
  _Alias({
    required this.phrase,
    required this.label,
    this.platforms,
    this.parentPlatform,
    this.catalogDates,
  }) : tokens = PlatformSearch._tokens(phrase);

  final String phrase;
  final String label;
  final String? platforms;
  final int? parentPlatform;
  final String? catalogDates;
  final List<String> tokens;

  PlatformSearch toSearch({String? text}) {
    final trimmed = text?.trim();
    final hasText = trimmed != null && trimmed.isNotEmpty;
    return PlatformSearch(
      label: label,
      platforms: platforms,
      parentPlatform: parentPlatform,
      dates: hasText ? null : catalogDates,
      text: hasText ? trimmed : null,
    );
  }
}

final List<_Alias> _aliases = _buildAliases();

final Map<String, _Alias> _aliasByKey = {
  for (final alias in _aliases) alias.phrase: alias,
};

List<_Alias> _expand({
  required List<String> phrases,
  required String label,
  String? platforms,
  int? parentPlatform,
  String? catalogDates,
}) {
  return [
    for (final phrase in phrases)
      _Alias(
        phrase: phrase,
        label: label,
        platforms: platforms,
        parentPlatform: parentPlatform,
        catalogDates: catalogDates,
      ),
  ];
}

List<_Alias> _buildAliases() {
  const switch2Dates = '2025-06-05,2035-12-31';
  final aliases = <_Alias>[
    ..._expand(
      phrases: const ['nintendo switch 2', 'switch 2', 'switch2', 'ns2'],
      label: 'Nintendo Switch 2',
      platforms: '7',
      catalogDates: switch2Dates,
    ),
    ..._expand(
      phrases: const ['nintendo switch', 'switch'],
      label: 'Nintendo Switch',
      platforms: '7',
    ),
    ..._expand(
      phrases: const ['nintendo 64', 'n64'],
      label: 'Nintendo 64',
      platforms: '83',
    ),
    ..._expand(
      phrases: const ['nintendo 3ds', '3ds'],
      label: 'Nintendo 3DS',
      platforms: '8',
    ),
    ..._expand(
      phrases: const ['nintendo ds', 'nds'],
      label: 'Nintendo DS',
      platforms: '9',
    ),
    ..._expand(
      phrases: const ['wii u'],
      label: 'Wii U',
      platforms: '10',
    ),
    ..._expand(
      phrases: const ['wii'],
      label: 'Wii',
      platforms: '11',
    ),
    ..._expand(
      phrases: const ['gamecube', 'game cube'],
      label: 'GameCube',
      platforms: '105',
    ),
    ..._expand(
      phrases: const ['game boy advance', 'gba'],
      label: 'Game Boy Advance',
      platforms: '24',
    ),
    ..._expand(
      phrases: const ['game boy'],
      label: 'Game Boy',
      platforms: '26',
    ),
    ..._expand(
      phrases: const ['snes', 'super nintendo'],
      label: 'SNES',
      platforms: '79',
    ),
    ..._expand(
      phrases: const ['nes'],
      label: 'NES',
      platforms: '49',
    ),
    ..._expand(
      phrases: const ['nintendo'],
      label: 'Nintendo',
      parentPlatform: 7,
    ),
    ..._expand(
      phrases: const ['playstation 5', 'play station 5', 'ps5'],
      label: 'PlayStation 5',
      platforms: '187',
    ),
    ..._expand(
      phrases: const ['playstation 4', 'play station 4', 'ps4'],
      label: 'PlayStation 4',
      platforms: '18',
    ),
    ..._expand(
      phrases: const ['playstation 3', 'play station 3', 'ps3'],
      label: 'PlayStation 3',
      platforms: '16',
    ),
    ..._expand(
      phrases: const ['playstation 2', 'play station 2', 'ps2'],
      label: 'PlayStation 2',
      platforms: '15',
    ),
    ..._expand(
      phrases: const ['playstation 1', 'play station 1', 'ps1', 'psx'],
      label: 'PlayStation',
      platforms: '27',
    ),
    ..._expand(
      phrases: const ['psp'],
      label: 'PSP',
      platforms: '17',
    ),
    ..._expand(
      phrases: const ['ps vita', 'playstation vita', 'psvita', 'vita'],
      label: 'PS Vita',
      platforms: '19',
    ),
    ..._expand(
      phrases: const ['playstation', 'play station', 'ps'],
      label: 'PlayStation',
      parentPlatform: 2,
    ),
    ..._expand(
      phrases: const [
        'xbox series x',
        'xbox series s',
        'xbox series',
        'series x',
        'xsx',
      ],
      label: 'Xbox Series X/S',
      platforms: '186',
    ),
    ..._expand(
      phrases: const ['xbox one', 'xboxone'],
      label: 'Xbox One',
      platforms: '1',
    ),
    ..._expand(
      phrases: const ['xbox 360', 'xbox360', 'x360'],
      label: 'Xbox 360',
      platforms: '14',
    ),
    ..._expand(
      phrases: const ['xbox'],
      label: 'Xbox',
      parentPlatform: 3,
    ),
    ..._expand(
      phrases: const ['pc', 'steam'],
      label: 'PC',
      platforms: '4',
    ),
  ];

  aliases.sort((a, b) {
    final byTokens = b.tokens.length.compareTo(a.tokens.length);
    if (byTokens != 0) {
      return byTokens;
    }
    return b.phrase.length.compareTo(a.phrase.length);
  });
  return aliases;
}
