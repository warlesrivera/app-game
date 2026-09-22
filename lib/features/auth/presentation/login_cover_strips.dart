import 'package:flutter/material.dart';

import '../../../app/di/injection.dart';
import '../../../app/theme/app_colors.dart';
import '../../games/domain/repositories/game_repository.dart';

class LoginCoverStrips extends StatefulWidget {
  const LoginCoverStrips({super.key});

  @override
  State<LoginCoverStrips> createState() => _LoginCoverStripsState();
}

class _LoginCoverStripsState extends State<LoginCoverStrips> {
  static const _fallback = [
    'assets/images/login_poster_1.png',
    'assets/images/login_poster_2.png',
    'assets/images/login_poster_3.png',
  ];

  List<String> _covers = _fallback;
  var _fromNetwork = false;

  @override
  void initState() {
    super.initState();
    _loadCovers();
  }

  Future<void> _loadCovers() async {
    if (!getIt.isRegistered<GameRepository>()) {
      return;
    }

    try {
      final games = await getIt<GameRepository>().getDiscoverGames();
      final urls = games
          .map((game) => game.coverUrl)
          .whereType<String>()
          .where((url) => url.isNotEmpty)
          .toList();
      if (!mounted || urls.isEmpty) {
        return;
      }
      setState(() {
        _covers = urls;
        _fromNetwork = true;
      });
    } catch (_) {
      // El fallback local mantiene el fondo si RAWG no responde.
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 720;
    final coverSize = isMobile ? const Size(98, 142) : const Size(126, 182);
    final left = _repeat(_covers, 15, offset: 0);
    final right = _repeat(_covers, 10, offset: 5);

    return IgnorePointer(
      child: _EdgeFade(
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: isMobile ? 28 : 48,
              top: isMobile ? 72 : 96,
              child: _FadedFilmStrip(
                covers: left,
                fromNetwork: _fromNetwork,
                angle: -0.42,
                alignment: Alignment.centerLeft,
                coverSize: coverSize,
              ),
            ),
            Positioned(
              right: isMobile ? 28 : 48,
              bottom: isMobile ? 72 : 96,
              child: _FadedFilmStrip(
                covers: right,
                fromNetwork: _fromNetwork,
                angle: -0.42,
                alignment: Alignment.centerRight,
                coverSize: coverSize,
              ),
            ),
            const Positioned.fill(child: _CenterReadabilityVeil()),
          ],
        ),
      ),
    );
  }

  List<String> _repeat(List<String> source, int count, {required int offset}) {
    if (source.isEmpty) {
      return const [];
    }
    return List<String>.generate(count, (index) {
      return source[(index + offset) % source.length];
    });
  }
}

class _FadedFilmStrip extends StatelessWidget {
  const _FadedFilmStrip({
    required this.covers,
    required this.fromNetwork,
    required this.angle,
    required this.alignment,
    required this.coverSize,
  });

  final List<String> covers;
  final bool fromNetwork;
  final double angle;
  final Alignment alignment;
  final Size coverSize;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      alignment: alignment,
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) {
          return const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0x00FFFFFF),
              Color(0xFFFFFFFF),
              Color(0xFFFFFFFF),
              Color(0x00FFFFFF),
            ],
            stops: [0.0, 0.12, 0.88, 1.0],
          ).createShader(rect);
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xF214161C),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x28FFFFFF)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final cover in covers)
                  _CoverFrame(
                    source: cover,
                    fromNetwork: fromNetwork,
                    size: coverSize,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EdgeFade extends StatelessWidget {
  const _EdgeFade({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x00FFFFFF),
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF),
            Color(0x00FFFFFF),
          ],
          stops: [0.0, 0.14, 0.86, 1.0],
        ).createShader(rect);
      },
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) {
          return const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0x00FFFFFF),
              Color(0xFFFFFFFF),
              Color(0xFFFFFFFF),
              Color(0x00FFFFFF),
            ],
            stops: [0.0, 0.12, 0.88, 1.0],
          ).createShader(rect);
        },
        child: child,
      ),
    );
  }
}

class _CenterReadabilityVeil extends StatelessWidget {
  const _CenterReadabilityVeil();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.64,
          colors: [
            AppColors.background,
            AppColors.background.withValues(alpha: 0.72),
            AppColors.background.withValues(alpha: 0.08),
            const Color(0x0007080B),
          ],
          stops: const [0.0, 0.34, 0.62, 1.0],
        ),
      ),
    );
  }
}

class _CoverFrame extends StatelessWidget {
  const _CoverFrame({
    required this.source,
    required this.fromNetwork,
    required this.size,
  });

  final String source;
  final bool fromNetwork;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: fromNetwork
              ? Image.network(
                  source,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (_, _, _) {
                    return ColoredBox(color: AppColors.surface);
                  },
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) {
                      return child;
                    }
                    return ColoredBox(color: AppColors.surfaceHigh);
                  },
                )
              : Image.asset(
                  source,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (_, _, _) {
                    return ColoredBox(color: AppColors.surface);
                  },
                ),
        ),
      ),
    );
  }
}
