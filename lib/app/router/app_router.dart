import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/go_router_refresh.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/splash_page.dart';
import '../../features/ai_chat/presentation/ai_chat_page.dart';
import '../../features/ai_chat/presentation/cubit/ai_chat_cubit.dart';
import '../../features/dashboard/presentation/catalog_collection/catalog_collection_cubit.dart';
import '../../features/dashboard/presentation/catalog_collection/catalog_collection_page.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/games/domain/models/game.dart';
import '../../features/games/presentation/game_details/game_details_flow.dart';
import '../../features/games/presentation/game_details/game_details_page.dart';
import '../../features/gaming_advisor/presentation/cubit/gaming_advisor_cubit.dart';
import '../../features/gaming_advisor/presentation/pages/gaming_advisor_page.dart';
import '../../features/gaming_advisor/presentation/pages/gaming_memory_page.dart';
import '../../features/gaming_advisor/presentation/pages/gaming_profile_page.dart';
import '../../features/library/presentation/library_page.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/search/presentation/cubit/search_cubit.dart';
import '../../features/search/presentation/search_page.dart';
import '../../features/wishlist/presentation/wishlist_page.dart';
import '../di/injection.dart';
import '../shell/app_shell.dart';

final class AppRouter {
  AppRouter({required AuthCubit authCubit})
    : _authCubit = authCubit,
      _refresh = GoRouterRefreshStream(authCubit.stream) {
    router = GoRouter(
      initialLocation: splash,
      refreshListenable: _refresh,
      redirect: (context, state) => _redirect(_authCubit.state, state),
      routes: [
        GoRoute(
          path: splash,
          name: 'splash',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: login,
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return AppShell(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: dashboard,
                  name: 'dashboard',
                  builder: (context, state) {
                    return BlocProvider(
                      create: (_) =>
                          getIt<DashboardCubit>()..loadDiscoverGames(),
                      child: const DashboardPage(),
                    );
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: search,
                  name: 'search',
                  builder: (context, state) {
                    return BlocProvider(
                      create: (_) => getIt<SearchCubit>(),
                      child: const SearchPage(),
                    );
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: library,
                  name: 'library',
                  builder: (context, state) => const LibraryPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: wishlist,
                  name: 'wishlist',
                  builder: (context, state) => const WishlistPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: profile,
                  name: 'profile',
                  builder: (context, state) {
                    return BlocProvider(
                      create: (_) => getIt<ProfileCubit>(),
                      child: const ProfilePage(),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => getIt<GamingAdvisorCubit>()..loadAdvisor(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: advisor,
              name: 'gamingAdvisor',
              builder: (context, state) {
                final extra = state.extra;
                return GamingAdvisorPage(
                  launch: extra is AdvisorLaunch ? extra : null,
                );
              },
              routes: [
                GoRoute(
                  path: 'profile',
                  name: 'gamingProfile',
                  builder: (context, state) => const GamingProfilePage(),
                ),
                GoRoute(
                  path: 'memory',
                  name: 'gamingMemory',
                  builder: (context, state) => const GamingMemoryPage(),
                ),
                GoRoute(
                  path: 'timeline',
                  name: 'gamingTimeline',
                  builder: (context, state) => const GamingTimelinePage(),
                ),
                GoRoute(
                  path: 'upcoming',
                  name: 'upcomingReleases',
                  builder: (context, state) => const UpcomingReleasesPage(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: catalogCollection,
          name: 'catalogCollection',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            final title = state.extra is String ? state.extra as String : id;
            return BlocProvider(
              create: (_) =>
                  getIt<CatalogCollectionCubit>(param1: id, param2: title)
                    ..load(),
              child: const CatalogCollectionPage(),
            );
          },
        ),
        GoRoute(
          path: gameDetails,
          name: 'gameDetails',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            final args = GameDetailsArgs.tryParse(state.extra);
            final preview = args?.game ?? Game(id: id, name: 'Juego');
            final heroTag = args?.heroTag ?? 'game-cover-$id';
            final games = args?.pages ?? [preview];
            return GameDetailsFlow(
              games: games,
              initialIndex: args?.initialIndex ?? 0,
              heroTag: heroTag,
            );
          },
          routes: [
            GoRoute(
              path: 'ai',
              name: 'aiChat',
              builder: (context, state) {
                final id = state.pathParameters['id'] ?? '';
                final extra = state.extra;
                final game = extra is Game
                    ? extra
                    : Game(id: id, name: 'Juego');
                return BlocProvider(
                  create: (_) =>
                      getIt<AiChatCubit>(param1: game, param2: game.name),
                  child: AiChatPage(gameName: game.name),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String search = '/search';
  static const String library = '/library';
  static const String wishlist = '/wishlist';
  static const String profile = '/profile';
  static const String advisor = '/advisor';
  static const String catalogCollection = '/catalog/:id';
  static const String gameDetails = '/game/:id';

  final AuthCubit _authCubit;
  final GoRouterRefreshStream _refresh;
  late final GoRouter router;

  static String? _redirect(AuthState authState, GoRouterState state) {
    final location = state.matchedLocation;
    final atLogin = location == login;
    final atSplash = location == splash;

    if (authState is AuthInitial) {
      return atSplash ? null : splash;
    }

    if (authState is AuthLoading) {
      return null;
    }

    if (authState is AuthAuthenticated) {
      return (atLogin || atSplash) ? dashboard : null;
    }

    return atLogin ? null : login;
  }

  void dispose() {
    _refresh.dispose();
    router.dispose();
  }
}
