import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/models/gaming_models.dart';
import '../cubit/gaming_advisor_cubit.dart';
import '../cubit/gaming_advisor_state.dart';

class GamingMemoryPage extends StatelessWidget {
  const GamingMemoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Memoria del Gaming Advisor'),
      ),
      body: BlocBuilder<GamingAdvisorCubit, GamingAdvisorState>(
        builder: (context, state) {
          if (state.memories.isEmpty) {
            return const Center(
              child: Text('Todavía no hay memorias. Cuéntale al advisor qué te gusta.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.memories.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final memory = state.memories[index];
              return ListTile(
                tileColor: AppColors.surfaceHigh,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                title: Text(memory.content),
                subtitle: Text(
                  '${memory.category.name} · confianza ${(memory.confidence * 100).round()}%',
                ),
                trailing: IconButton(
                  tooltip: 'Eliminar',
                  onPressed: () =>
                      context.read<GamingAdvisorCubit>().deleteMemory(memory.id),
                  icon: const Icon(Icons.delete_outline),
                ),
                onTap: () => _edit(context, memory),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _edit(BuildContext context, GamingMemory memory) async {
    final controller = TextEditingController(text: memory.content);
    final next = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar memoria'),
          content: TextField(controller: controller, maxLines: 3),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
    if (next == null || next.isEmpty || !context.mounted) {
      return;
    }
    await context.read<GamingAdvisorCubit>().saveMemory(
      memory.copyWith(content: next, updatedAt: DateTime.now()),
    );
  }
}

class GamingTimelinePage extends StatelessWidget {
  const GamingTimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Mi aventura'),
      ),
      body: BlocBuilder<GamingAdvisorCubit, GamingAdvisorState>(
        builder: (context, state) {
          if (state.timeline.isEmpty) {
            return const Center(child: Text('Tu aventura empieza cuando marques juegos.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final lane in ['Completados', 'Jugando', 'Próximos']) ...[
                Text(lane.toUpperCase(), style: TextStyle(color: AppColors.accent)),
                const SizedBox(height: 8),
                for (final stop in state.timeline.where((item) => item.lane == lane))
                  ListTile(
                    title: Text(stop.title),
                    leading: const Icon(Icons.arrow_downward_rounded),
                    onTap: () => context.push('/game/${stop.gameId}'),
                  ),
                const SizedBox(height: 16),
              ],
            ],
          );
        },
      ),
    );
  }
}

class UpcomingReleasesPage extends StatelessWidget {
  const UpcomingReleasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Próximamente'),
      ),
      body: BlocBuilder<GamingAdvisorCubit, GamingAdvisorState>(
        builder: (context, state) {
          if (state.upcoming.isEmpty) {
            return const Center(child: Text('No hay lanzamientos en tu wishlist.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.upcoming.length,
            itemBuilder: (context, index) {
              final item = state.upcoming[index];
              final date = item.releaseDate;
              final label = date == null
                  ? 'Fecha desconocida'
                  : '${date.day}/${date.month}/${date.year}';
              return ListTile(
                title: Text(item.title),
                subtitle: Text(
                  '$label · ${item.status ?? ''} · ${item.platforms.take(2).join(', ')}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
