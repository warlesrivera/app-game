import 'package:equatable/equatable.dart';

enum MemoryCategory {
  preference,
  dislike,
  habit,
  favorite,
  completedGame,
  abandonedGame,
  currentGame,
  playstyle,
  difficulty,
  recommendationFeedback,
}

enum PlayReaction { loved, liked, neutral, disliked, hated }

class GamingProfile extends Equatable {
  const GamingProfile({
    this.storyImportance = 3,
    this.combatImportance = 3,
    this.explorationImportance = 3,
    this.equipmentImportance = 3,
    this.buildImportance = 3,
    this.characterProgressionImportance = 3,
    this.difficultyTolerance = 3,
    this.objectiveClarityImportance = 3,
    this.repetitionTolerance = 3,
    this.mainStoryPreference = true,
    this.playsMostlyWeekends = false,
    this.likes = const [],
    this.dislikes = const [],
    this.currentGameId,
    this.progress,
    this.currentAct,
    this.estimatedHoursPlayed,
    this.lastPlayedAt,
    this.version = 1,
    this.conversationSummary = '',
  });

  final int storyImportance;
  final int combatImportance;
  final int explorationImportance;
  final int equipmentImportance;
  final int buildImportance;
  final int characterProgressionImportance;
  final int difficultyTolerance;
  final int objectiveClarityImportance;
  final int repetitionTolerance;
  final bool mainStoryPreference;
  final bool playsMostlyWeekends;
  final List<String> likes;
  final List<String> dislikes;
  final String? currentGameId;
  final int? progress;
  final String? currentAct;
  final double? estimatedHoursPlayed;
  final DateTime? lastPlayedAt;
  final int version;
  final String conversationSummary;

  static const fields = <String, String>{
    'storyImportance': 'Historia',
    'combatImportance': 'Combate',
    'explorationImportance': 'Exploración',
    'equipmentImportance': 'Equipamiento',
    'buildImportance': 'Builds',
    'characterProgressionImportance': 'Progresión',
    'difficultyTolerance': 'Dificultad',
    'objectiveClarityImportance': 'Objetivos claros',
    'repetitionTolerance': 'Repetición',
  };

  int valueOf(String field) => switch (field) {
    'storyImportance' => storyImportance,
    'combatImportance' => combatImportance,
    'explorationImportance' => explorationImportance,
    'equipmentImportance' => equipmentImportance,
    'buildImportance' => buildImportance,
    'characterProgressionImportance' => characterProgressionImportance,
    'difficultyTolerance' => difficultyTolerance,
    'objectiveClarityImportance' => objectiveClarityImportance,
    'repetitionTolerance' => repetitionTolerance,
    _ => 3,
  };

  GamingProfile copyWith({
    int? storyImportance,
    int? combatImportance,
    int? explorationImportance,
    int? equipmentImportance,
    int? buildImportance,
    int? characterProgressionImportance,
    int? difficultyTolerance,
    int? objectiveClarityImportance,
    int? repetitionTolerance,
    bool? mainStoryPreference,
    bool? playsMostlyWeekends,
    List<String>? likes,
    List<String>? dislikes,
    String? currentGameId,
    bool clearCurrentGame = false,
    int? progress,
    String? currentAct,
    double? estimatedHoursPlayed,
    DateTime? lastPlayedAt,
    int? version,
    String? conversationSummary,
  }) {
    return GamingProfile(
      storyImportance: storyImportance ?? this.storyImportance,
      combatImportance: combatImportance ?? this.combatImportance,
      explorationImportance: explorationImportance ?? this.explorationImportance,
      equipmentImportance: equipmentImportance ?? this.equipmentImportance,
      buildImportance: buildImportance ?? this.buildImportance,
      characterProgressionImportance:
          characterProgressionImportance ?? this.characterProgressionImportance,
      difficultyTolerance: difficultyTolerance ?? this.difficultyTolerance,
      objectiveClarityImportance:
          objectiveClarityImportance ?? this.objectiveClarityImportance,
      repetitionTolerance: repetitionTolerance ?? this.repetitionTolerance,
      mainStoryPreference: mainStoryPreference ?? this.mainStoryPreference,
      playsMostlyWeekends: playsMostlyWeekends ?? this.playsMostlyWeekends,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      currentGameId: clearCurrentGame ? null : currentGameId ?? this.currentGameId,
      progress: progress ?? this.progress,
      currentAct: currentAct ?? this.currentAct,
      estimatedHoursPlayed: estimatedHoursPlayed ?? this.estimatedHoursPlayed,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      version: version ?? this.version,
      conversationSummary: conversationSummary ?? this.conversationSummary,
    );
  }

  GamingProfile withField(String field, int value) {
    final clamped = value.clamp(1, 5);
    return switch (field) {
      'storyImportance' => copyWith(storyImportance: clamped, version: version + 1),
      'combatImportance' => copyWith(combatImportance: clamped, version: version + 1),
      'explorationImportance' =>
        copyWith(explorationImportance: clamped, version: version + 1),
      'equipmentImportance' =>
        copyWith(equipmentImportance: clamped, version: version + 1),
      'buildImportance' => copyWith(buildImportance: clamped, version: version + 1),
      'characterProgressionImportance' => copyWith(
        characterProgressionImportance: clamped,
        version: version + 1,
      ),
      'difficultyTolerance' =>
        copyWith(difficultyTolerance: clamped, version: version + 1),
      'objectiveClarityImportance' =>
        copyWith(objectiveClarityImportance: clamped, version: version + 1),
      'repetitionTolerance' =>
        copyWith(repetitionTolerance: clamped, version: version + 1),
      _ => this,
    };
  }

  String compactLine() {
    String level(int value) => value >= 4 ? 'alto' : (value <= 2 ? 'bajo' : 'medio');
    return 'Historia ${level(storyImportance)}, combate ${level(combatImportance)}, '
        'exploración ${level(explorationImportance)}, equipo ${level(equipmentImportance)}, '
        'claridad de objetivos ${level(objectiveClarityImportance)}, '
        'tolerancia a repetición ${level(repetitionTolerance)}.'
        '${playsMostlyWeekends ? ' Juega sobre todo los fines de semana.' : ''}';
  }

  Map<String, dynamic> toJson() => {
    'storyImportance': storyImportance,
    'combatImportance': combatImportance,
    'explorationImportance': explorationImportance,
    'equipmentImportance': equipmentImportance,
    'buildImportance': buildImportance,
    'characterProgressionImportance': characterProgressionImportance,
    'difficultyTolerance': difficultyTolerance,
    'objectiveClarityImportance': objectiveClarityImportance,
    'repetitionTolerance': repetitionTolerance,
    'mainStoryPreference': mainStoryPreference,
    'playsMostlyWeekends': playsMostlyWeekends,
    'likes': likes,
    'dislikes': dislikes,
    'currentGameId': currentGameId,
    'progress': progress,
    'currentAct': currentAct,
    'estimatedHoursPlayed': estimatedHoursPlayed,
    'lastPlayedAt': lastPlayedAt?.toIso8601String(),
    'version': version,
    'conversationSummary': conversationSummary,
  };

  factory GamingProfile.fromJson(Map<String, dynamic> json) {
    int read(String key) => (json[key] as num?)?.toInt().clamp(1, 5) ?? 3;
    return GamingProfile(
      storyImportance: read('storyImportance'),
      combatImportance: read('combatImportance'),
      explorationImportance: read('explorationImportance'),
      equipmentImportance: read('equipmentImportance'),
      buildImportance: read('buildImportance'),
      characterProgressionImportance: read('characterProgressionImportance'),
      difficultyTolerance: read('difficultyTolerance'),
      objectiveClarityImportance: read('objectiveClarityImportance'),
      repetitionTolerance: read('repetitionTolerance'),
      mainStoryPreference: json['mainStoryPreference'] as bool? ?? true,
      playsMostlyWeekends: json['playsMostlyWeekends'] as bool? ?? false,
      likes: _strings(json['likes']),
      dislikes: _strings(json['dislikes']),
      currentGameId: json['currentGameId'] as String?,
      progress: (json['progress'] as num?)?.toInt(),
      currentAct: json['currentAct'] as String?,
      estimatedHoursPlayed: (json['estimatedHoursPlayed'] as num?)?.toDouble(),
      lastPlayedAt: DateTime.tryParse('${json['lastPlayedAt'] ?? ''}'),
      version: (json['version'] as num?)?.toInt() ?? 1,
      conversationSummary: json['conversationSummary'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [
    storyImportance,
    combatImportance,
    explorationImportance,
    equipmentImportance,
    buildImportance,
    characterProgressionImportance,
    difficultyTolerance,
    objectiveClarityImportance,
    repetitionTolerance,
    mainStoryPreference,
    playsMostlyWeekends,
    likes,
    dislikes,
    currentGameId,
    progress,
    currentAct,
    estimatedHoursPlayed,
    lastPlayedAt,
    version,
    conversationSummary,
  ];
}

class GamingMemory extends Equatable {
  const GamingMemory({
    required this.id,
    required this.category,
    required this.content,
    this.importance = 0.6,
    this.confidence = 0.6,
    this.source = 'chat',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final MemoryCategory category;
  final String content;
  final double importance;
  final double confidence;
  final String source;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GamingMemory copyWith({
    String? content,
    double? importance,
    double? confidence,
    DateTime? updatedAt,
  }) {
    return GamingMemory(
      id: id,
      category: category,
      content: content ?? this.content,
      importance: importance ?? this.importance,
      confidence: confidence ?? this.confidence,
      source: source,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'category': category.name,
    'content': content,
    'importance': importance,
    'confidence': confidence,
    'source': source,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory GamingMemory.fromJson(String id, Map<String, dynamic> json) {
    return GamingMemory(
      id: id,
      category: MemoryCategory.values.asNameMap()['${json['category']}'] ??
          MemoryCategory.preference,
      content: '${json['content'] ?? ''}',
      importance: (json['importance'] as num?)?.toDouble() ?? 0.6,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.6,
      source: '${json['source'] ?? 'chat'}',
      createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
      updatedAt: DateTime.tryParse('${json['updatedAt'] ?? ''}'),
    );
  }

  @override
  List<Object?> get props => [id, category, content, importance, confidence];
}

class GameExperience extends Equatable {
  const GameExperience({
    required this.gameId,
    required this.status,
    this.reaction,
    this.highlights = const [],
    this.whyLiked,
    this.whyDisliked,
    this.completedAt,
  });

  final String gameId;
  final String status;
  final PlayReaction? reaction;
  final List<String> highlights;
  final String? whyLiked;
  final String? whyDisliked;
  final DateTime? completedAt;

  Map<String, dynamic> toJson() => {
    'status': status,
    'reaction': reaction?.name,
    'highlights': highlights,
    'whyLiked': whyLiked,
    'whyDisliked': whyDisliked,
    'completedAt': completedAt?.toIso8601String(),
  };

  factory GameExperience.fromJson(String gameId, Map<String, dynamic> json) {
    return GameExperience(
      gameId: gameId,
      status: '${json['status'] ?? ''}',
      reaction: PlayReaction.values.asNameMap()['${json['reaction']}'],
      highlights: _strings(json['highlights']),
      whyLiked: json['whyLiked'] as String?,
      whyDisliked: json['whyDisliked'] as String?,
      completedAt: DateTime.tryParse('${json['completedAt'] ?? ''}'),
    );
  }

  @override
  List<Object?> get props => [gameId, status, reaction, highlights];
}

class AdvisorRecommendation extends Equatable {
  const AdvisorRecommendation({
    required this.gameId,
    required this.name,
    this.coverUrl,
    this.status,
    this.platforms = const [],
    this.releaseLabel,
    this.reasons = const [],
    this.warning,
  });

  final String gameId;
  final String name;
  final String? coverUrl;
  final String? status;
  final List<String> platforms;
  final String? releaseLabel;
  final List<String> reasons;
  final String? warning;

  @override
  List<Object?> get props => [gameId, name, reasons, warning];
}

class AdvisorMessage extends Equatable {
  const AdvisorMessage({
    required this.id,
    required this.role,
    required this.text,
    this.cards = const [],
    this.createdAt,
  });

  final String id;
  final String role;
  final String text;
  final List<AdvisorRecommendation> cards;
  final DateTime? createdAt;

  bool get isUser => role == 'user';

  Map<String, dynamic> toJson() => {
    'role': role,
    'text': text,
    'createdAt': createdAt?.toIso8601String(),
  };

  factory AdvisorMessage.fromJson(String id, Map<String, dynamic> json) {
    return AdvisorMessage(
      id: id,
      role: '${json['role'] ?? 'assistant'}',
      text: '${json['text'] ?? ''}',
      createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
    );
  }

  @override
  List<Object?> get props => [id, role, text, cards];
}

class UpcomingRelease extends Equatable {
  const UpcomingRelease({
    required this.gameId,
    required this.title,
    this.releaseDate,
    this.platforms = const [],
    this.status,
    this.coverUrl,
  });

  final String gameId;
  final String title;
  final DateTime? releaseDate;
  final List<String> platforms;
  final String? status;
  final String? coverUrl;

  @override
  List<Object?> get props => [gameId, title, releaseDate, status];
}

class TimelineStop extends Equatable {
  const TimelineStop({
    required this.gameId,
    required this.title,
    required this.lane,
    this.coverUrl,
    this.when,
  });

  final String gameId;
  final String title;
  final String lane;
  final String? coverUrl;
  final DateTime? when;

  @override
  List<Object?> get props => [gameId, lane, title];
}

List<String> _strings(Object? raw) {
  if (raw is! List) {
    return const [];
  }
  return [for (final item in raw) '$item'.trim()].where((item) => item.isNotEmpty).toList();
}
