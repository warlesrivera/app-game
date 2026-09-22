import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/network/connectivity_bloc.dart';
import '../core/widgets/offline_banner.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/library/presentation/cubit/library_cubit.dart';
import 'di/injection.dart';
import 'router/app_router.dart';
import 'theme/app_colors.dart';
import 'theme/app_palette.dart';
import 'theme/app_theme.dart';
import 'theme/appearance_cubit.dart';

class GameVaultApp extends StatefulWidget {
  const GameVaultApp({super.key, required this.authCubit});

  final AuthCubit authCubit;

  @override
  State<GameVaultApp> createState() => _GameVaultAppState();
}

class _GameVaultAppState extends State<GameVaultApp> {
  late final AppRouter _appRouter = AppRouter(authCubit: widget.authCubit);
  late final AppearanceCubit _appearance = AppearanceCubit();

  @override
  void dispose() {
    _appRouter.dispose();
    _appearance.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.authCubit),
        BlocProvider.value(value: _appearance),
        if (getIt.isRegistered<LibraryCubit>())
          BlocProvider(create: (_) => getIt<LibraryCubit>()..start()),
        if (getIt.isRegistered<ConnectivityBloc>())
          BlocProvider(
            create: (_) =>
                getIt<ConnectivityBloc>()..add(const ConnectivityStarted()),
          ),
      ],
      child: BlocBuilder<AppearanceCubit, AppearanceState>(
        builder: (context, appearance) {
          final platform =
              WidgetsBinding.instance.platformDispatcher.platformBrightness;
          final palette = appearance.paletteFor(platform);
          AppColors.bind(palette);
          return MaterialApp.router(
            title: 'GameVault',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.from(AppPalette.light(appearance.accent)),
            darkTheme: AppTheme.from(AppPalette.dark(appearance.accent)),
            themeMode: appearance.mode,
            routerConfig: _appRouter.router,
            builder: (context, child) {
              final brightness = Theme.of(context).brightness;
              final resolved = appearance.paletteFor(brightness);
              AppColors.bind(resolved);
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: AppTheme.systemUiFor(resolved),
                child: Column(
                  children: [
                    const OfflineBanner(),
                    Expanded(child: child ?? const SizedBox.shrink()),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
