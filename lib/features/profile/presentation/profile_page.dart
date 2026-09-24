import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../app/di/injection.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/game_card.dart';
import '../../../core/widgets/game_grid.dart';
import '../../auth/domain/entities/app_user.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../auth/presentation/cubit/auth_state.dart';
import '../../games/domain/models/game.dart';
import '../../games/presentation/game_details/game_details_page.dart';
import '../../library/domain/models/library_game.dart';
import '../../library/domain/models/library_status.dart';
import '../../library/presentation/cubit/library_cubit.dart';
import '../../library/presentation/cubit/library_state.dart';
import '../domain/models/amiibo_character.dart';
import '../domain/usecases/get_amiibo_characters.dart';
import 'cubit/profile_cubit.dart';
import 'cubit/profile_state.dart';
import 'favorites_tab.dart';
import 'widgets/appearance_card.dart';
import 'widgets/genre_radar_card.dart';
import 'widgets/player_lore_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<ProfileCubit>().sync(context.read<LibraryCubit>().state);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LibraryCubit, LibraryState>(
      listenWhen: (previous, current) {
        if (previous is LibraryLoaded && current is LibraryLoaded) {
          return previous.games != current.games ||
              previous.stats != current.stats;
        }
        return previous.runtimeType != current.runtimeType;
      },
      listener: (context, state) {
        context.read<ProfileCubit>().sync(state);
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Text(
                    'JUGADOR',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.accent,
                      letterSpacing: 2.2,
                    ),
                  ),
                ),
                TabBar(
                  labelColor: AppColors.accent,
                  unselectedLabelColor: AppColors.onSurfaceMuted,
                  indicatorColor: AppColors.accent,
                  dividerColor: AppColors.outline,
                  tabs: [
                    Tab(text: 'Perfil'),
                    Tab(text: 'Favoritos'),
                  ],
                ),
                const Expanded(
                  child: TabBarView(children: [_ProfileTab(), FavoritesTab()]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      children: [
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final user = state is AuthAuthenticated ? state.user : null;
            if (user == null) {
              return const SizedBox.shrink();
            }
            return _ProfileHeader(user: user);
          },
        ),
                const SizedBox(height: 32),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.psychology_alt_outlined, color: AppColors.accent),
                  title: const Text('Gaming Advisor'),
                  subtitle: const Text('Tu biblioteca. Tus gustos. Tu próxima aventura.'),
                  onTap: () => context.pushNamed('gamingAdvisor'),
                ),
                BlocBuilder<LibraryCubit, LibraryState>(
          builder: (context, state) {
            final stats = state.stats;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ESTADÍSTICAS',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.accent,
                    letterSpacing: 2.2,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _StatCard(label: 'Jugados', value: stats.played),
                    _StatCard(label: 'Completados', value: stats.completed),
                    _StatCard(label: 'En Wishlist', value: stats.wishlist),
                    _StatCard(label: 'Abandonados', value: stats.abandoned),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'GÉNEROS MÁS JUGADOS',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.accent,
                    letterSpacing: 2.2,
                  ),
                ),
                const SizedBox(height: 12),
                if (state.topGenres.isEmpty)
                  Text(
                    'Aún no hay suficientes partidas para calcular tus géneros.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceMuted,
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final genre in state.topGenres)
                        Chip(
                          label: Text('${genre.key}  ·  ${genre.value}'),
                          backgroundColor: AppColors.surfaceHigh,
                          side: BorderSide(color: AppColors.outline),
                          labelStyle: TextStyle(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 28),
                BlocBuilder<ProfileCubit, ProfileInsightState>(
                  builder: (context, insight) {
                    return Column(
                      children: [
                        GenreRadarCard(radar: insight.radar),
                        const SizedBox(height: 16),
                        PlayerLoreCard(
                          analysis: insight.analysis,
                          loading: insight.loadingLore,
                          needsSync: insight.needsSync,
                          error: insight.error,
                          onSeeMore: insight.analysis == null
                              ? null
                              : () => showPlayerAnalysisDetails(
                                  context,
                                  insight.analysis!,
                                ),
                          onRefresh: () =>
                              context.read<ProfileCubit>().refreshAnalysis(),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),
                _HallOfFame(favorites: state.favoriteGames),
              ],
            );
          },
        ),
        const SizedBox(height: 28),
        const AppearanceCard(),
        const SizedBox(height: 36),
        OutlinedButton.icon(
          onPressed: () => context.read<AuthCubit>().signOut(),
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Cerrar sesión'),
        ),
      ],
    );
  }
}

class _FameMark {
  const _FameMark({required this.label, required this.color});

  final String label;
  final Color color;
}

_FameMark _fameMarkFor(int? rank) {
  return switch (rank) {
    1 => const _FameMark(label: '1.º  Oro', color: Color(0xFFD4AF37)),
    2 => const _FameMark(label: '2.º  Plata', color: Color(0xFFC0C6CE)),
    3 => const _FameMark(label: '3.º  Cobre', color: Color(0xFFB87333)),
    _ => const _FameMark(label: 'Salón', color: Color(0xFF4ADE80)),
  };
}

class _HallOfFame extends StatefulWidget {
  const _HallOfFame({required this.favorites});

  final List<LibraryGame> favorites;

  @override
  State<_HallOfFame> createState() => _HallOfFameState();
}

class _HallOfFameState extends State<_HallOfFame> {
  static const _layoutKey = 'fame_layout';

  var _layout = LibraryLayout.grid;

  @override
  void initState() {
    super.initState();
    _layout = _readLayout();
  }

  LibraryLayout _readLayout() {
    try {
      final raw = Hive.box<dynamic>('game_cache').get(_layoutKey);
      return raw == LibraryLayout.list.name
          ? LibraryLayout.list
          : LibraryLayout.grid;
    } catch (_) {
      return LibraryLayout.grid;
    }
  }

  Future<void> _toggleLayout() async {
    setState(() {
      _layout = _layout == LibraryLayout.grid
          ? LibraryLayout.list
          : LibraryLayout.grid;
    });
    try {
      if (!Hive.isBoxOpen('game_cache')) {
        return;
      }
      await Hive.box<dynamic>('game_cache').put(_layoutKey, _layout.name);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isList = _layout == LibraryLayout.list;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'SALÓN DE LA FAMA',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.accent,
                  letterSpacing: 2.2,
                ),
              ),
            ),
            if (widget.favorites.isNotEmpty)
              IconButton(
                tooltip: isList ? 'Ver portadas' : 'Ver lista',
                onPressed: _toggleLayout,
                icon: Icon(
                  isList ? Icons.grid_view_rounded : Icons.view_list_rounded,
                  color: AppColors.onSurface,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (widget.favorites.isEmpty)
          Text(
            'Completa un juego y márcalo como favorito para llenar tu salón.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceMuted),
          )
        else if (isList)
          _FameList(favorites: widget.favorites)
        else
          _FameGrid(favorites: widget.favorites),
      ],
    );
  }
}

class _FameGrid extends StatelessWidget {
  const _FameGrid({required this.favorites});

  final List<LibraryGame> favorites;

  @override
  Widget build(BuildContext context) {
    final queue = [for (final item in favorites) item.game];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: GameGrid.delegate,
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final item = favorites[index];
        final heroTag = 'fame-${item.game.id}';
        final mark = _fameMarkFor(item.entry.favoriteRank);
        return GameCard(
          game: item.game,
          heroTag: heroTag,
          fill: true,
          frameColor: mark.color,
          badgeLabel: mark.label,
          badgeColor: mark.color,
          onTap: () => openGameDetails(
            context,
            item.game,
            heroTag: heroTag,
            queue: queue,
          ),
        );
      },
    );
  }
}

class _FameList extends StatelessWidget {
  const _FameList({required this.favorites});

  final List<LibraryGame> favorites;

  @override
  Widget build(BuildContext context) {
    final queue = [for (final item in favorites) item.game];
    return Column(
      children: [
        for (var index = 0; index < favorites.length; index += 1) ...[
          if (index > 0) Divider(height: 1, color: AppColors.outline),
          _FameListTile(item: favorites[index], queue: queue),
        ],
      ],
    );
  }
}

class _FameListTile extends StatelessWidget {
  const _FameListTile({required this.item, required this.queue});

  final LibraryGame item;
  final List<Game> queue;

  @override
  Widget build(BuildContext context) {
    final heroTag = 'fame-${item.game.id}';
    final mark = _fameMarkFor(item.entry.favoriteRank);
    return Stack(
      children: [
        GameListRow(
          game: item.game,
          heroTag: heroTag,
          onTap: () => openGameDetails(
            context,
            item.game,
            heroTag: heroTag,
            queue: queue,
          ),
        ),
        Positioned(
          top: 10,
          left: 12,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: mark.color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              child: Text(
                mark.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.background,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final name = user.name.trim().isNotEmpty ? user.name : 'Gamer';

    return Row(
      children: [
        GestureDetector(
          onTap: () => _openAvatarPicker(context, user),
          child: Stack(
            children: [
              _PlayerAvatar(user: user, radius: 36),
              Positioned(
                right: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 14,
                      color: AppColors.background,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(user.email, style: textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(
                'Toca el avatar para elegir un juego',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlayerAvatar extends StatelessWidget {
  const _PlayerAvatar({required this.user, this.radius = 32});

  final AppUser user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: user.hasCustomAvatar
            ? CachedNetworkImage(
                imageUrl: user.avatarUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => ColoredBox(
                  color: AppColors.surfaceHigh,
                  child: Icon(Icons.person_rounded, color: AppColors.accent),
                ),
                errorWidget: (_, _, _) => _DicebearAvatar(user: user),
              )
            : _DicebearAvatar(user: user),
      ),
    );
  }
}

class _DicebearAvatar extends StatelessWidget {
  const _DicebearAvatar({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceHigh,
      child: SvgPicture.network(
        user.dicebearUrl,
        fit: BoxFit.cover,
        placeholderBuilder: (_) => Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: AppColors.accent),
              ),
              const SizedBox(height: 6),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _openAvatarPicker(BuildContext context, AppUser user) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return _AvatarPickerSheet(user: user);
    },
  );
}

class _AvatarPickerSheet extends StatefulWidget {
  const _AvatarPickerSheet({required this.user});

  final AppUser user;

  @override
  State<_AvatarPickerSheet> createState() => _AvatarPickerSheetState();
}

class _AvatarPickerSheetState extends State<_AvatarPickerSheet> {
  final _query = TextEditingController();
  var _loading = true;
  var _searching = false;
  var _saving = false;
  String? _error;
  List<AmiiboCharacter> _all = const [];
  Timer? _debounce;
  int _searchToken = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  Future<void> _load([String query = '']) async {
    final token = ++_searchToken;
    setState(() {
      if (_all.isEmpty) {
        _loading = true;
      } else {
        _searching = true;
      }
      _error = null;
    });
    try {
      final characters = await getIt<GetAmiiboCharacters>()(query: query);
      if (!mounted || token != _searchToken) {
        return;
      }
      setState(() {
        _all = characters;
        _loading = false;
        _searching = false;
      });
    } catch (_) {
      if (!mounted || token != _searchToken) {
        return;
      }
      setState(() {
        _loading = false;
        _searching = false;
        _error = 'No se pudieron cargar los avatares.';
      });
    }
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _load(value);
    });
  }

  List<AmiiboCharacter> get _visible => _all;

  Future<void> _select(AmiiboCharacter character) async {
    setState(() => _saving = true);
    try {
      await context.read<AuthCubit>().updateAvatar(character.imageUrl);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar el avatar.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.78;
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Elige tu avatar',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _query,
              onChanged: _onQueryChanged,
              textInputAction: TextInputAction.search,
              onSubmitted: _load,
              decoration: InputDecoration(
                hintText: 'Buscar cualquier juego',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    )
                  : _error != null
                  ? Center(
                      child: TextButton(
                        onPressed: () => _load(_query.text),
                        child: Text(_error!),
                      ),
                    )
                  : _visible.isEmpty
                  ? const Center(
                      child: Text('No encontramos juegos con esa búsqueda.'),
                    )
                  : GridView.builder(
                      itemCount: _visible.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.78,
                          ),
                      itemBuilder: (context, index) {
                        final item = _visible[index];
                        final selected = widget.user.avatarUrl == item.imageUrl;
                        return InkWell(
                          onTap: _saving ? null : () => _select(item),
                          borderRadius: BorderRadius.circular(16),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceHigh,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selected
                                    ? AppColors.accent
                                    : AppColors.outline,
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: CachedNetworkImage(
                                      imageUrl: item.imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (_, _) => ColoredBox(
                                        color: AppColors.surfaceHigh,
                                      ),
                                      errorWidget: (_, _, _) => Icon(
                                        Icons.sports_esports_rounded,
                                        color: AppColors.onSurfaceMuted,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
