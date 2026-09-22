import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/models/genre_radar.dart';

class GenreRadarCard extends StatelessWidget {
  const GenreRadarCard({super.key, required this.radar});

  final GenreRadar radar;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RADAR DE GÉNEROS',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.accent,
                letterSpacing: 1.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              radar.hasData
                  ? 'Basado en juegos que estás jugando o ya completaste.'
                  : 'Completa o juega títulos para dibujar tu pentágono gamer.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceMuted),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: radar.hasData
                  ? RadarChart(
                      RadarChartData(
                        dataSets: [
                          RadarDataSet(
                            fillColor: AppColors.accent.withValues(alpha: 0.22),
                            borderColor: AppColors.accent,
                            borderWidth: 2.2,
                            entryRadius: 3.5,
                            dataEntries: [
                              for (final axis in radar.axes)
                                RadarEntry(
                                  value: axis.value == 0 ? 0.08 : axis.value,
                                ),
                            ],
                          ),
                        ],
                        radarBackgroundColor: Colors.transparent,
                        radarBorderData: BorderSide(
                          color: AppColors.outline,
                        ),
                        tickBorderData: BorderSide(
                          color: AppColors.outline.withValues(alpha: 0.7),
                        ),
                        gridBorderData: BorderSide(
                          color: AppColors.outline.withValues(alpha: 0.7),
                        ),
                        ticksTextStyle: const TextStyle(
                          color: Colors.transparent,
                          fontSize: 0,
                        ),
                        tickCount: 3,
                        titleTextStyle: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                        titlePositionPercentageOffset: 0.08,
                        getTitle: (index, _) {
                          final axis = radar.axes[index];
                          return RadarChartTitle(
                            text: axis.label,
                            positionPercentageOffset: 0.12,
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.hexagon_outlined,
                        size: 72,
                        color: AppColors.outline,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
