import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/network/api_client.dart';
import '../../core/network/connectivity_bloc.dart';
import '../../features/ai_chat/data/datasources/ai_chat_remote_datasource.dart';
import '../../features/ai_chat/data/providers/gemini_ai_provider.dart';
import '../../features/ai_chat/data/repositories/game_ai_repository_impl.dart';
import '../../features/ai_chat/domain/repositories/game_ai_repository.dart';
import '../../features/ai_chat/domain/usecases/send_ai_message.dart';
import '../../features/ai_chat/domain/usecases/watch_ai_messages.dart';
import '../../features/ai_chat/presentation/cubit/ai_chat_cubit.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/datasources/firebase_auth_remote_datasource.dart';
import '../../features/auth/data/datasources/firestore_user_remote_datasource.dart';
import '../../features/auth/data/datasources/user_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_with_email.dart';
import '../../features/auth/domain/usecases/sign_in_with_google.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/sign_up_with_email.dart';
import '../../features/auth/domain/usecases/update_avatar_url.dart';
import '../../features/auth/domain/usecases/watch_auth_state.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/dashboard/presentation/catalog_collection/catalog_collection_cubit.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../features/games/data/datasources/game_local_cache.dart';
import '../../features/games/data/datasources/hive_game_local_cache.dart';
import '../../features/games/data/datasources/on_device_translation_service.dart';
import '../../features/games/data/datasources/rawg_remote_datasource.dart';
import '../../features/games/data/datasources/wikipedia_guide_remote_datasource.dart';
import '../../features/games/data/repositories/game_guide_repository_impl.dart';
import '../../features/games/data/repositories/game_repository_impl.dart';
import '../../features/games/domain/models/game.dart';
import '../../features/games/domain/repositories/game_guide_repository.dart';
import '../../features/games/domain/repositories/game_repository.dart';
import '../../features/games/domain/repositories/game_translator.dart';
import '../../features/games/domain/usecases/get_catalog_collection.dart';
import '../../features/games/domain/usecases/get_catalog_rows.dart';
import '../../features/games/domain/usecases/get_discover_games_usecase.dart';
import '../../features/games/domain/usecases/get_game_details.dart';
import '../../features/games/domain/usecases/get_game_guide.dart';
import '../../features/games/domain/usecases/get_games_by_ids.dart';
import '../../features/games/domain/usecases/search_games_usecase.dart';
import '../../features/games/domain/usecases/translate_game_description.dart';
import '../../features/games/presentation/game_details/game_details_cubit.dart';
import '../../features/library/data/datasources/library_remote_datasource.dart';
import '../../features/library/data/repositories/library_repository_impl.dart';
import '../../features/library/domain/repositories/library_repository.dart';
import '../../features/library/domain/usecases/remove_game_from_library.dart';
import '../../features/library/domain/usecases/set_favorite_rank.dart';
import '../../features/library/domain/usecases/set_game_favorite.dart';
import '../../features/library/domain/usecases/set_game_status.dart';
import '../../features/library/domain/usecases/watch_library.dart';
import '../../features/library/presentation/cubit/library_cubit.dart';
import '../../features/prices/data/datasources/cheapshark_remote_datasource.dart';
import '../../features/prices/data/repositories/price_repository_impl.dart';
import '../../features/prices/domain/repositories/price_repository.dart';
import '../../features/prices/domain/usecases/get_game_deal.dart';
import '../../features/prices/domain/usecases/save_price_alert.dart';
import '../../features/profile/data/datasources/player_analysis_remote_datasource.dart';
import '../../features/profile/domain/usecases/generate_player_profile.dart';
import '../../features/profile/domain/usecases/get_amiibo_characters.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/search/presentation/cubit/search_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<AuthCubit>()) {
    await getIt.reset();
  }

  final gameCacheBox = Hive.isBoxOpen(HiveGameLocalCache.boxName)
      ? Hive.box<dynamic>(HiveGameLocalCache.boxName)
      : await Hive.openBox<dynamic>(HiveGameLocalCache.boxName);

  getIt
    ..registerLazySingleton(
      () => ApiClient(
        baseUrl: dotenv.env['RAWG_BASE_URL'] ?? '',
        apiKey: dotenv.env['RAWG_API_KEY'] ?? '',
      ),
    )
    ..registerLazySingleton(() => RawgRemoteDataSource(getIt()))
    ..registerLazySingleton<GameLocalCache>(
      () => HiveGameLocalCache(gameCacheBox),
    )
    ..registerLazySingleton<GameRepository>(
      () => GameRepositoryImpl(remoteDataSource: getIt(), localCache: getIt()),
    )
    ..registerLazySingleton(() => GetDiscoverGamesUseCase(getIt()))
    ..registerLazySingleton(() => SearchGamesUseCase(getIt()))
    ..registerLazySingleton(() => GetGamesByIds(getIt()))
    ..registerLazySingleton(() => GetGameDetails(getIt()))
    ..registerLazySingleton(() => GetCatalogRowsUseCase(getIt()))
    ..registerLazySingleton(() => GetCatalogCollection(getIt()))
    ..registerLazySingleton(WikipediaGuideRemoteDataSource.new)
    ..registerLazySingleton<GameGuideRepository>(
      () => GameGuideRepositoryImpl(wikipedia: getIt(), localCache: getIt()),
    )
    ..registerLazySingleton(() => GetGameGuide(getIt()))
    ..registerLazySingleton<GameTranslator>(OnDeviceTranslationService.new)
    ..registerLazySingleton(
      () => TranslateGameDescription(
        translator: getIt(),
        gameRepository: getIt(),
      ),
    )
    ..registerFactoryParam<GameDetailsCubit, Game, String>(
      (game, _) => GameDetailsCubit(
        preview: game,
        getGameDetails: getIt(),
        translateDescription: getIt(),
        getGameGuide: getIt(),
        getGameDeal: getIt(),
      ),
    )
    ..registerFactory(() => DashboardCubit(getCatalogRows: getIt()))
    ..registerFactoryParam<CatalogCollectionCubit, String, String>(
      (id, title) => CatalogCollectionCubit(
        catalogId: id,
        title: title,
        getCatalogCollection: getIt(),
      ),
    )
    ..registerFactory(() => SearchCubit(searchGames: getIt()))
    ..registerFactory(() => ConnectivityBloc())
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => FirebaseAuthRemoteDataSource(
        serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'],
      ),
    )
    ..registerLazySingleton<UserRemoteDataSource>(
      FirestoreUserRemoteDataSource.new,
    )
    ..registerLazySingleton<AuthRepository>(
      () =>
          AuthRepositoryImpl(authDataSource: getIt(), userDataSource: getIt()),
    )
    ..registerLazySingleton(() => WatchAuthState(getIt()))
    ..registerLazySingleton(() => SignInWithEmail(getIt()))
    ..registerLazySingleton(() => SignUpWithEmail(getIt()))
    ..registerLazySingleton(() => SignInWithGoogle(getIt()))
    ..registerLazySingleton(() => SignOut(getIt()))
    ..registerLazySingleton(() => UpdateAvatarUrl(getIt()))
    ..registerLazySingleton(
      () => AuthCubit(
        watchAuthState: getIt(),
        signInWithEmail: getIt(),
        signUpWithEmail: getIt(),
        signInWithGoogle: getIt(),
        signOut: getIt(),
        updateAvatarUrl: getIt(),
      ),
    )
    ..registerLazySingleton(() => GetAmiiboCharacters(getIt()))
    ..registerLazySingleton(() => GeneratePlayerProfile(getIt()))
    ..registerLazySingleton(PlayerAnalysisRemoteDataSource.new)
    ..registerFactory(
      () =>
          ProfileCubit(generatePlayerProfile: getIt(), analysisRemote: getIt()),
    )
    ..registerLazySingleton(LibraryRemoteDataSource.new)
    ..registerLazySingleton<LibraryRepository>(
      () => LibraryRepositoryImpl(getIt()),
    )
    ..registerLazySingleton(() => WatchLibrary(getIt()))
    ..registerLazySingleton(() => SetGameStatus(getIt()))
    ..registerLazySingleton(() => RemoveGameFromLibrary(getIt()))
    ..registerLazySingleton(() => SetGameFavorite(getIt()))
    ..registerLazySingleton(() => SetFavoriteRank(getIt()))
    ..registerLazySingleton(
      () => CheapSharkRemoteDataSource(cache: gameCacheBox),
    )
    ..registerLazySingleton<PriceRepository>(
      () => PriceRepositoryImpl(getIt(), getIt()),
    )
    ..registerLazySingleton(() => SavePriceAlert(getIt()))
    ..registerLazySingleton(() => GetGameDeal(getIt()))
    ..registerFactory(
      () => LibraryCubit(
        watchAuthState: getIt(),
        watchLibrary: getIt(),
        setGameStatus: getIt(),
        removeGameFromLibrary: getIt(),
        setGameFavorite: getIt(),
        setFavoriteRank: getIt(),
        getGamesByIds: getIt(),
        savePriceAlert: getIt(),
        getGameDeal: getIt(),
      ),
    )
    ..registerLazySingleton(AiChatRemoteDataSource.new)
    ..registerLazySingleton(
      () => GeminiAiProvider(apiKey: dotenv.env['GEMINI_API_KEY'] ?? ''),
    )
    ..registerLazySingleton<GameAIRepository>(
      () => GameAIRepositoryImpl(remote: getIt(), provider: getIt()),
    )
    ..registerLazySingleton(() => SendAiMessage(getIt()))
    ..registerLazySingleton(() => WatchAiMessages(getIt()))
    ..registerFactoryParam<AiChatCubit, Game, String>(
      (game, _) => AiChatCubit(
        game: game,
        sendAiMessage: getIt(),
        watchAiMessages: getIt(),
      ),
    );
}
