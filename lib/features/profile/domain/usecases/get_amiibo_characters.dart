import '../../../games/domain/repositories/game_repository.dart';
import '../models/amiibo_character.dart';

class GetAmiiboCharacters {
  const GetAmiiboCharacters(this._repository);

  final GameRepository _repository;

  Future<List<AmiiboCharacter>> call({String query = ''}) async {
    final games = query.trim().isEmpty
        ? await _repository.getDiscoverGames()
        : await _repository.searchGames(query.trim());

    return [
      for (final game in games)
        if (game.coverUrl != null && game.coverUrl!.trim().isNotEmpty)
          AmiiboCharacter(
            id: game.id,
            name: game.name,
            imageUrl: game.coverUrl!,
            gameSeries: game.genres.isNotEmpty ? game.genres.first : null,
          ),
    ];
  }
}
