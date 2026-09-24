import 'package:flutter/material.dart';

import '../../../app/di/injection.dart';
import '../../../app/theme/app_colors.dart';
import '../domain/models/gaming_models.dart';
import '../domain/repositories/gaming_advisor_repository.dart';

Future<void> showCompletedFeedback(
  BuildContext context, {
  required String gameId,
  required String gameName,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    builder: (context) {
      return _CompletedFeedback(gameId: gameId, gameName: gameName);
    },
  );
}

class _CompletedFeedback extends StatefulWidget {
  const _CompletedFeedback({required this.gameId, required this.gameName});

  final String gameId;
  final String gameName;

  @override
  State<_CompletedFeedback> createState() => _CompletedFeedbackState();
}

class _CompletedFeedbackState extends State<_CompletedFeedback> {
  PlayReaction? _reaction;
  final _highlights = <String>{};

  static const _options = [
    (PlayReaction.loved, 'Me encantó'),
    (PlayReaction.liked, 'Me gustó'),
    (PlayReaction.neutral, 'Normal'),
    (PlayReaction.disliked, 'No me gustó'),
    (PlayReaction.hated, 'Lo odié'),
  ];

  static const _features = [
    'Historia',
    'Combate',
    'Exploración',
    'Personajes',
    'Mundo',
    'Equipamiento',
    'Progresión',
    'Dificultad',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('¿Qué te pareció ${widget.gameName}?'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final option in _options)
                ChoiceChip(
                  label: Text(option.$2),
                  selected: _reaction == option.$1,
                  onSelected: (_) => setState(() => _reaction = option.$1),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('¿Qué fue lo que más te gustó?'),
          Wrap(
            spacing: 8,
            children: [
              for (final feature in _features)
                FilterChip(
                  label: Text(feature),
                  selected: _highlights.contains(feature),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _highlights.add(feature);
                      } else {
                        _highlights.remove(feature);
                      }
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _reaction == null ? null : _save,
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final reaction = _reaction;
    if (reaction == null) {
      return;
    }
    final liked = reaction == PlayReaction.loved || reaction == PlayReaction.liked;
    await getIt<GamingAdvisorRepository>().saveExperience(
      GameExperience(
        gameId: widget.gameId,
        status: 'completed',
        reaction: reaction,
        highlights: _highlights.toList(),
        whyLiked: liked ? _highlights.join(', ') : null,
        whyDisliked: liked ? null : _highlights.join(', '),
        completedAt: DateTime.now(),
      ),
    );
    if (!mounted) {
      return;
    }
    Navigator.pop(context);
  }
}
