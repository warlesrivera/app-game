import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/models/player_analysis.dart';

class PlayerLoreCard extends StatelessWidget {
  const PlayerLoreCard({
    super.key,
    required this.analysis,
    required this.loading,
    required this.needsSync,
    this.error,
    this.onSeeMore,
    this.onRefresh,
  });

  final PlayerAnalysis? analysis;
  final bool loading;
  final bool needsSync;
  final String? error;
  final VoidCallback? onSeeMore;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final current = analysis;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ANÁLISIS IA',
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.accent,
                letterSpacing: 1.8,
              ),
            ),
            const SizedBox(height: 12),
            if (loading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
              )
            else if (current == null)
              Text(
                'Cuando tengas partidas suficientes, Gemini escribirá tu leyenda gamer aquí.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              )
            else ...[
              Text(
                current.title,
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (current.summary.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(current.summary, style: textTheme.bodyMedium),
              ],
              if (current.details.isNotEmpty) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onSeeMore,
                    icon: const Icon(Icons.menu_book_rounded, size: 18),
                    label: const Text('Ver más'),
                  ),
                ),
              ],
            ],
            if (needsSync && !loading) ...[
              const SizedBox(height: 8),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0x3324D3EE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.45),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.sync_problem_rounded,
                        color: AppColors.accent,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          current == null
                              ? 'Hay datos nuevos. Genera tu análisis.'
                              : 'Tus favoritos o partidas cambiaron. Falta sincronizar el análisis.',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (error != null && !loading) ...[
              const SizedBox(height: 8),
              Text(
                error!,
                style: textTheme.bodySmall?.copyWith(color: AppColors.error),
              ),
            ],
            if ((needsSync || current == null) && !loading && onRefresh != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.auto_awesome),
                    label: Text(
                      current == null
                          ? 'Analizar perfil'
                          : 'Actualizar análisis',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> showPlayerAnalysisDetails(
  BuildContext context,
  PlayerAnalysis analysis,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      final textTheme = Theme.of(sheetContext).textTheme;
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Por qué este perfil',
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.accent,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                analysis.title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (analysis.summary.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(analysis.summary, style: textTheme.bodyLarge),
              ],
              if (analysis.details.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  analysis.details,
                  style: textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}
