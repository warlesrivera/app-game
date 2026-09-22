import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/theme/app_colors.dart';
import '../network/connectivity_bloc.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final hasBloc = _hasConnectivityBloc(context);
    if (!hasBloc) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
      builder: (context, state) {
        if (!state.isOffline) {
          return const SizedBox.shrink();
        }
        return Material(
          color: Color(0xFF3A2A14),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 16,
                    color: AppColors.accent,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Sin conexión. Mostrando datos en caché.',
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool _hasConnectivityBloc(BuildContext context) {
    try {
      context.read<ConnectivityBloc>();
      return true;
    } catch (_) {
      return false;
    }
  }
}
