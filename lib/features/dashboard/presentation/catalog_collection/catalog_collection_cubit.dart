import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../games/domain/models/catalog_collection.dart';
import '../../../games/domain/models/game.dart';
import '../../../games/domain/usecases/get_catalog_collection.dart';
import '../../../library/domain/models/library_status.dart';
import 'catalog_collection_state.dart';

class CatalogCollectionCubit extends Cubit<CatalogCollectionState> {
  CatalogCollectionCubit({
    required String catalogId,
    required String title,
    required GetCatalogCollection getCatalogCollection,
  }) : _catalogId = catalogId,
       _getCatalogCollection = getCatalogCollection,
       super(
         CatalogCollectionState(
           title: title,
           layout: _readLayout(),
           loading: true,
         ),
       );

  final String _catalogId;
  final GetCatalogCollection _getCatalogCollection;
  static const _layoutKey = 'library_layout';

  Future<void> load() async {
    final queries = _getCatalogCollection.queriesFor(
      catalogId: _catalogId,
      title: state.title,
    );
    if (queries.isEmpty) {
      emit(state.copyWith(loading: false, sections: const []));
      return;
    }

    final sections = [
      for (final query in queries)
        CatalogSection(
          id: query.id,
          title: query.title,
          query: query,
        ),
    ];
    emit(
      state.copyWith(
        sections: sections,
        selectedId: sections.first.id,
        loading: false,
        clearError: true,
      ),
    );
    await ensureSection(sections.first.id);
  }

  Future<void> selectSection(String id) async {
    if (state.selectedId == id) {
      return;
    }
    emit(state.copyWith(selectedId: id, clearError: true));
    await ensureSection(id);
  }

  Future<void> ensureSection(String id) async {
    final section = _section(id);
    if (section == null || section.loading || section.games.isNotEmpty) {
      return;
    }
    await _fetch(id, page: 1, append: false);
  }

  Future<void> loadMore(String id) async {
    final section = _section(id);
    if (section == null ||
        !section.hasMore ||
        section.loadingMore ||
        section.loading) {
      return;
    }
    await _fetch(id, page: section.page + 1, append: true);
  }

  void toggleLayout() {
    final layout = state.layout == LibraryLayout.grid
        ? LibraryLayout.list
        : LibraryLayout.grid;
    emit(state.copyWith(layout: layout));
    _saveLayout(layout);
  }

  Future<void> _fetch(
    String id, {
    required int page,
    required bool append,
  }) async {
    final current = _section(id);
    if (current == null) {
      return;
    }

    _replace(
      current.copyWith(
        loading: !append,
        loadingMore: append,
      ),
    );

    try {
      final games = await _getCatalogCollection.loadSection(
        query: current.query,
        page: page,
      );
      if (isClosed) {
        return;
      }
      final merged = append
          ? _uniqueGames([...current.games, ...games])
          : games;
      _replace(
        current.copyWith(
          games: merged,
          page: page,
          hasMore: games.length >= GetCatalogCollection.previewPageSize,
          loading: false,
          loadingMore: false,
        ),
      );
    } catch (error) {
      if (isClosed) {
        return;
      }
      _replace(
        current.copyWith(
          loading: false,
          loadingMore: false,
        ),
      );
      if (!append && current.games.isEmpty) {
        emit(
          state.copyWith(
            error: error is Failure
                ? error.message
                : 'No se pudo cargar esta consola.',
          ),
        );
      }
    }
  }

  CatalogSection? _section(String id) {
    for (final section in state.sections) {
      if (section.id == id) {
        return section;
      }
    }
    return null;
  }

  void _replace(CatalogSection next) {
    emit(
      state.copyWith(
        sections: [
          for (final section in state.sections)
            if (section.id == next.id) next else section,
        ],
      ),
    );
  }

  List<Game> _uniqueGames(List<Game> games) {
    final seen = <String>{};
    return [
      for (final game in games)
        if (seen.add(game.id)) game,
    ];
  }

  static LibraryLayout _readLayout() {
    try {
      final raw = Hive.box<dynamic>('game_cache').get(_layoutKey);
      return LibraryLayout.values.asNameMap()[raw] ?? LibraryLayout.grid;
    } catch (_) {
      return LibraryLayout.grid;
    }
  }

  Future<void> _saveLayout(LibraryLayout layout) async {
    try {
      await Hive.box<dynamic>('game_cache').put(_layoutKey, layout.name);
    } catch (_) {}
  }
}
