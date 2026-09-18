import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/network/connectivity_bloc.dart';
import '../core/widgets/offline_banner.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/library/presentation/cubit/library_cubit.dart';
import 'di/injection.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class GameVaultApp extends StatefulWidget {
  const GameVaultApp({super.key, required this.authCubit});

  final AuthCubit authCubit;

  @override
  State<GameVaultApp> createState() => _GameVaultAppState();
}

class _GameVaultAppState extends State<GameVaultApp> {
  late final AppRouter _appRouter = AppRouter(authCubit: widget.authCubit);

  @override
  void dispose() {
    _appRouter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.authCubit),
        if (getIt.isRegistered<LibraryCubit>())
          BlocProvider(create: (_) => getIt<LibraryCubit>()..start()),
        if (getIt.isRegistered<ConnectivityBloc>())
          BlocProvider(
            create: (_) =>
                getIt<ConnectivityBloc>()..add(const ConnectivityStarted()),
          ),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppTheme.systemUi,
        child: MaterialApp.router(
          title: 'GameVault',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          routerConfig: _appRouter.router,
          builder: (context, child) {
            return Column(
              children: [
                const OfflineBanner(),
                Expanded(child: child ?? const SizedBox.shrink()),
              ],
            );
          },
        ),
      ),
    );
  }
}
