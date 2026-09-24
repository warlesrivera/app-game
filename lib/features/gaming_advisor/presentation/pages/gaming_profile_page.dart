import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/models/gaming_models.dart';
import '../cubit/gaming_advisor_cubit.dart';
import '../cubit/gaming_advisor_state.dart';

class GamingProfilePage extends StatelessWidget {
  const GamingProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Mi perfil de jugador'),
      ),
      body: BlocBuilder<GamingAdvisorCubit, GamingAdvisorState>(
        builder: (context, state) {
          final profile = state.profile;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('Lo que más valoro'),
              for (final field in GamingProfile.fields.entries)
                _SliderRow(
                  label: field.value,
                  value: profile.valueOf(field.key),
                  onChanged: (value) {
                    context.read<GamingAdvisorCubit>().updatePreference(
                      profile.withField(field.key, value.round()),
                    );
                  },
                ),
              SwitchListTile(
                title: const Text('Prefiero la historia principal'),
                value: profile.mainStoryPreference,
                onChanged: (value) {
                  context.read<GamingAdvisorCubit>().updatePreference(
                    profile.copyWith(
                      mainStoryPreference: value,
                      version: profile.version + 1,
                    ),
                  );
                },
              ),
              SwitchListTile(
                title: const Text('Cómo juego: sobre todo fines de semana'),
                value: profile.playsMostlyWeekends,
                onChanged: (value) {
                  context.read<GamingAdvisorCubit>().updatePreference(
                    profile.copyWith(
                      playsMostlyWeekends: value,
                      version: profile.version + 1,
                    ),
                  );
                },
              ),
              _ChipEditor(
                title: 'Me gusta',
                values: profile.likes,
                onChanged: (values) {
                  context.read<GamingAdvisorCubit>().updatePreference(
                    profile.copyWith(likes: values, version: profile.version + 1),
                  );
                },
              ),
              _ChipEditor(
                title: 'No me gusta',
                values: profile.dislikes,
                onChanged: (values) {
                  context.read<GamingAdvisorCubit>().updatePreference(
                    profile.copyWith(dislikes: values, version: profile.version + 1),
                  );
                },
              ),
              ListTile(
                title: const Text('Próximamente'),
                subtitle: const Text('Fechas de lanzamiento de tu wishlist'),
                onTap: () => context.pushNamed('upcomingReleases'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label · $value'),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          label: '$value',
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ChipEditor extends StatefulWidget {
  const _ChipEditor({
    required this.title,
    required this.values,
    required this.onChanged,
  });

  final String title;
  final List<String> values;
  final ValueChanged<List<String>> onChanged;

  @override
  State<_ChipEditor> createState() => _ChipEditorState();
}

class _ChipEditorState extends State<_ChipEditor> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(widget.title),
        Wrap(
          spacing: 8,
          children: [
            for (final value in widget.values)
              InputChip(
                label: Text(value),
                onDeleted: () {
                  widget.onChanged([
                    for (final item in widget.values)
                      if (item != value) item,
                  ]);
                },
              ),
          ],
        ),
        TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: 'Agregar y pulsar enter'),
          onSubmitted: (value) {
            final text = value.trim();
            if (text.isEmpty) {
              return;
            }
            widget.onChanged([...widget.values, text]);
            _controller.clear();
          },
        ),
      ],
    );
  }
}
