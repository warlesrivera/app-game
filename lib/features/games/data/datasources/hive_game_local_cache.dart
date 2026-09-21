import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/models/game.dart';
import '../../domain/models/game_guide.dart';
import 'game_local_cache.dart';

class HiveGameLocalCache implements GameLocalCache {
  HiveGameLocalCache(
    this._box, {
    this.ttl = const Duration(minutes: 60),
  });

  static const String boxName = 'game_cache';
  static const String _cachedAtKey = 'cachedAt';
  static const String _gamesKey = 'games';

  final Box<dynamic> _box;
  final Duration ttl;

  @override
  Future<List<Game>?> getDiscoverGames({required int page}) {
    return _read(_discoverKey(page));
  }

  @override
  Future<void> saveDiscoverGames({
    required int page,
    required List<Game> games,
  }) async {
    await _write(_discoverKey(page), games);
    await _indexGames(games);
  }

  @override
  Future<List<Game>?> getSearchGames({required String query}) {
    return _read(_searchKey(query));
  }

  @override
  Future<void> saveSearchGames({
    required String query,
    required List<Game> games,
  }) async {
    await _write(_searchKey(query), games);
    await _indexGames(games);
  }

  @override
  Future<Game?> getGame(String id) async {
    final raw = _box.get(_gameKey(id));
    if (raw is! Map) {
      return null;
    }
    final cachedAtMillis = raw[_cachedAtKey] as int?;
    if (cachedAtMillis == null) {
      return null;
    }
    final cachedAt = DateTime.fromMillisecondsSinceEpoch(cachedAtMillis);
    if (DateTime.now().difference(cachedAt) >= const Duration(days: 7)) {
      await _box.delete(_gameKey(id));
      return null;
    }
    final json = raw['game'];
    if (json is! Map) {
      return null;
    }
    return Game.fromJson(Map<String, dynamic>.from(json));
  }

  @override
  Future<void> saveGame(Game game) async {
    if (!game.isDetailed) {
      final existing = await getGame(game.id);
      if (existing != null && existing.isDetailed) {
        return;
      }
    }

    await _box.put(_gameKey(game.id), {
      _cachedAtKey: DateTime.now().millisecondsSinceEpoch,
      'game': game.toJson(),
    });
  }

  Future<List<Game>?> _read(String key) async {
    final raw = _box.get(key);
    if (raw is! Map) {
      return null;
    }

    final cachedAtMillis = raw[_cachedAtKey] as int?;
    if (cachedAtMillis == null) {
      return null;
    }

    final cachedAt = DateTime.fromMillisecondsSinceEpoch(cachedAtMillis);
    final isFresh = DateTime.now().difference(cachedAt) < ttl;
    if (!isFresh) {
      await _box.delete(key);
      return null;
    }

    final games = raw[_gamesKey];
    if (games is! List) {
      return null;
    }

    return games
        .whereType<Map>()
        .map((item) => Game.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> _write(String key, List<Game> games) {
    return _box.put(key, {
      _cachedAtKey: DateTime.now().millisecondsSinceEpoch,
      _gamesKey: games.map((game) => game.toJson()).toList(),
    });
  }

  String _discoverKey(int page) => 'discover_page_$page';

  String _searchKey(String query) {
    final normalized = query.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    return 'search_$normalized';
  }

  String _gameKey(String id) => 'game_$id';

  String _catalogKey(String catalogId) => 'catalog_v3_$catalogId';

  String _guideKey(String gameId) => 'guide_$gameId';

  @override
  Future<List<Game>?> getCatalog(String catalogId) {
    return _read(_catalogKey(catalogId));
  }

  @override
  Future<void> saveCatalog({
    required String catalogId,
    required List<Game> games,
  }) async {
    await _write(_catalogKey(catalogId), games);
    await _indexGames(games);
  }

  @override
  Future<GameGuide?> getGuide(String gameId) async {
    final raw = _box.get(_guideKey(gameId));
    if (raw is! Map) {
      return null;
    }
    final cachedAtMillis = raw[_cachedAtKey] as int?;
    if (cachedAtMillis == null) {
      return null;
    }
    final cachedAt = DateTime.fromMillisecondsSinceEpoch(cachedAtMillis);
    if (DateTime.now().difference(cachedAt) >= const Duration(days: 7)) {
      await _box.delete(_guideKey(gameId));
      return null;
    }
    final json = raw['guide'];
    if (json is! Map) {
      return null;
    }
    return GameGuide.fromJson(Map<String, dynamic>.from(json));
  }

  @override
  Future<void> saveGuide({
    required String gameId,
    required GameGuide guide,
  }) {
    return _box.put(_guideKey(gameId), {
      _cachedAtKey: DateTime.now().millisecondsSinceEpoch,
      'guide': guide.toJson(),
    });
  }

  Future<void> _indexGames(List<Game> games) async {
    for (final game in games) {
      await saveGame(game);
    }
  }
}
