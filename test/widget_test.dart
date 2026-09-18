import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamevault/app/app.dart';
import 'package:gamevault/app/di/injection.dart';
import 'package:gamevault/core/widgets/game_card.dart';
import 'package:gamevault/features/auth/domain/entities/app_user.dart';
import 'package:gamevault/features/auth/domain/repositories/auth_repository.dart';
import 'package:gamevault/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:gamevault/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:gamevault/features/auth/domain/usecases/sign_out.dart';
import 'package:gamevault/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:gamevault/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:gamevault/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gamevault/features/auth/presentation/login_page.dart';
import 'package:gamevault/features/auth/presentation/splash_page.dart';
import 'package:gamevault/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:gamevault/features/dashboard/presentation/dashboard_page.dart';
import 'package:gamevault/features/games/domain/models/game.dart';
import 'package:gamevault/features/games/domain/repositories/game_repository.dart';
import 'package:gamevault/features/games/presentation/game_details/game_details_page.dart';
import 'package:gamevault/features/games/domain/usecases/get_discover_games_usecase.dart';
import 'package:gamevault/features/games/domain/usecases/get_games_by_ids.dart';
import 'package:gamevault/features/games/domain/usecases/search_games_usecase.dart';
import 'package:gamevault/features/library/domain/models/library_entry.dart';
import 'package:gamevault/features/library/domain/models/library_status.dart';
import 'package:gamevault/features/library/domain/repositories/library_repository.dart';
import 'package:gamevault/features/library/domain/usecases/set_game_status.dart';
import 'package:gamevault/features/library/domain/usecases/watch_library.dart';
import 'package:gamevault/features/library/presentation/cubit/library_cubit.dart';
import 'package:gamevault/features/library/presentation/library_page.dart';
import 'package:gamevault/features/prices/domain/repositories/price_repository.dart';
import 'package:gamevault/features/prices/domain/usecases/save_price_alert.dart';
import 'package:gamevault/features/search/presentation/cubit/search_cubit.dart';
import 'package:gamevault/features/search/presentation/search_page.dart';
import 'package:google_fonts/google_fonts.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(Stream<AppUser?> stream)
    : _stream = stream.asBroadcastStream();

  final Stream<AppUser?> _stream;

  @override
  Stream<AppUser?> watchAuthState() => _stream;

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {}
}

class _FakeGameRepository implements GameRepository {
  static const discover = [
    Game(
      id: 'elden-1',
      name: 'Elden Ring',
      description: 'A dark fantasy adventure.',
      rating: 4.6,
      platforms: ['PlayStation 5', 'PC'],
      genres: ['RPG', 'Action'],
    ),
  ];

  @override
  Future<List<Game>> getDiscoverGames({int page = 1}) async => discover;

  @override
  Future<List<Game>> searchGames(String query) async => const [];

  @override
  Future<Game?> getGameById(String id) async {
    for (final game in discover) {
      if (game.id == id) {
        return game;
      }
    }
    return null;
  }

  @override
  Future<List<Game>> getGamesByIds(List<String> ids) async {
    final games = <Game>[];
    for (final id in ids) {
      final game = await getGameById(id);
      if (game != null) {
        games.add(game);
      }
    }
    return games;
  }
}

class _IdleAuthRepository implements AuthRepository {
  @override
  Stream<AppUser?> watchAuthState() => Stream<AppUser?>.value(null);

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {}
}

class _FakeLibraryRepository implements LibraryRepository {
  @override
  Stream<List<LibraryEntry>> watchEntries() => Stream.value(const []);

  @override
  Future<LibraryEntry?> getEntry(String gameId) async => null;

  @override
  Future<void> setStatus({
    required String gameId,
    required LibraryStatus status,
  }) async {}
}

class _FakePriceRepository implements PriceRepository {
  @override
  Future<void> savePriceAlert({
    required String gameId,
    required bool enabled,
    required List<String> stores,
  }) async {}
}

AuthCubit _buildCubit(Stream<AppUser?> stream) {
  final repository = _FakeAuthRepository(stream);
  return AuthCubit(
    watchAuthState: WatchAuthState(repository),
    signInWithEmail: SignInWithEmail(repository),
    signUpWithEmail: SignUpWithEmail(repository),
    signInWithGoogle: SignInWithGoogle(repository),
    signOut: SignOut(repository),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    getIt
      ..registerLazySingleton<AuthRepository>(_IdleAuthRepository.new)
      ..registerLazySingleton(() => WatchAuthState(getIt()))
      ..registerLazySingleton<GameRepository>(_FakeGameRepository.new)
      ..registerLazySingleton(() => GetDiscoverGamesUseCase(getIt()))
      ..registerLazySingleton(() => SearchGamesUseCase(getIt()))
      ..registerLazySingleton(() => GetGamesByIds(getIt()))
      ..registerLazySingleton<LibraryRepository>(_FakeLibraryRepository.new)
      ..registerLazySingleton(() => WatchLibrary(getIt()))
      ..registerLazySingleton(() => SetGameStatus(getIt()))
      ..registerLazySingleton<PriceRepository>(_FakePriceRepository.new)
      ..registerLazySingleton(() => SavePriceAlert(getIt()))
      ..registerFactory(() => DashboardCubit(getDiscoverGames: getIt()))
      ..registerFactory(() => SearchCubit(searchGames: getIt()))
      ..registerFactory(
        () => LibraryCubit(
          watchAuthState: getIt(),
          watchLibrary: getIt(),
          setGameStatus: getIt(),
          getGamesByIds: getIt(),
          savePriceAlert: getIt(),
        ),
      );
  });

  tearDownAll(getIt.reset);

  testWidgets('muestra el Splash mientras Auth está en initial', (tester) async {
    final cubit = _buildCubit(const Stream.empty());
    addTearDown(cubit.close);

    await tester.pumpWidget(GameVaultApp(authCubit: cubit));
    await tester.pump();

    expect(find.byType(SplashPage), findsOneWidget);
    expect(find.text('GAMEVAULT'), findsOneWidget);
  });

  testWidgets('redirige a Login si no hay sesión', (tester) async {
    final cubit = _buildCubit(Stream<AppUser?>.value(null));
    addTearDown(cubit.close);

    await tester.pumpWidget(GameVaultApp(authCubit: cubit));
    await tester.pump();
    await tester.pump();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets('permite cambiar a modo registro', (tester) async {
    final cubit = _buildCubit(Stream<AppUser?>.value(null));
    addTearDown(cubit.close);

    await tester.pumpWidget(GameVaultApp(authCubit: cubit));
    await tester.pump();
    await tester.pump();

    final registerLink = find.text('¿No tienes cuenta? Regístrate');
    await tester.ensureVisible(registerLink);
    await tester.tap(registerLink);
    await tester.pump();

    expect(find.text('Crear cuenta'), findsOneWidget);
    expect(find.text('Nombre'), findsOneWidget);
    expect(find.text('Continuar con Google'), findsOneWidget);
  });

  testWidgets('redirige a Dashboard si hay sesión', (tester) async {
    const user = AppUser(
      id: 'uid-1',
      email: 'player@gamevault.app',
      name: 'Player',
      age: 0,
      avatarId: 'avatar_01',
    );
    final cubit = _buildCubit(Stream<AppUser?>.value(user));
    addTearDown(cubit.close);

    await tester.pumpWidget(GameVaultApp(authCubit: cubit));
    await tester.pump();
    await tester.pump();

    expect(find.byType(DashboardPage), findsOneWidget);
    expect(find.text('Hola, Player'), findsOneWidget);
    expect(find.text('DESCUBRE'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Buscar'), findsOneWidget);
    expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
  });

  testWidgets('cambia a Buscar y Biblioteca desde el menú inferior', (
    tester,
  ) async {
    const user = AppUser(
      id: 'uid-1',
      email: 'player@gamevault.app',
      name: 'Player',
      age: 0,
      avatarId: 'avatar_01',
    );
    final cubit = _buildCubit(Stream<AppUser?>.value(user));
    addTearDown(cubit.close);

    await tester.pumpWidget(GameVaultApp(authCubit: cubit));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Buscar'));
    await tester.pump();
    await tester.pump();

    expect(find.byType(SearchPage), findsOneWidget);
    expect(find.text('Escribe para descubrir juegos.'), findsOneWidget);

    await tester.tap(find.text('Biblioteca'));
    await tester.pump();
    await tester.pump();

    expect(find.byType(LibraryPage), findsOneWidget);
    expect(find.text('Biblioteca'), findsWidgets);
  });

  testWidgets('logout redirige a Login', (tester) async {
    const user = AppUser(
      id: 'uid-1',
      email: 'player@gamevault.app',
      name: 'Player',
      age: 0,
      avatarId: 'avatar_01',
    );
    final cubit = _buildCubit(Stream<AppUser?>.value(user));
    addTearDown(cubit.close);

    await tester.pumpWidget(GameVaultApp(authCubit: cubit));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byIcon(Icons.logout_rounded));
    await tester.pump();
    await tester.pump();

    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('abre Game Details desde una GameCard', (tester) async {
    const user = AppUser(
      id: 'uid-1',
      email: 'player@gamevault.app',
      name: 'Player',
      age: 0,
      avatarId: 'avatar_01',
    );
    final cubit = _buildCubit(Stream<AppUser?>.value(user));
    addTearDown(cubit.close);

    await tester.pumpWidget(GameVaultApp(authCubit: cubit));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byType(GameCard));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 550));

    expect(find.byType(GameDetailsPage), findsOneWidget);
    expect(find.text('Completado'), findsOneWidget);
    expect(find.text('Wishlist'), findsOneWidget);
    expect(find.text('A dark fantasy adventure.'), findsOneWidget);
  });
}
