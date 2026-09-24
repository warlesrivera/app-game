import 'package:equatable/equatable.dart';

import '../../domain/models/gaming_models.dart';

enum AdvisorStatus { initial, loading, loaded, sending, success, error }

class GamingAdvisorState extends Equatable {
  const GamingAdvisorState({
    this.status = AdvisorStatus.initial,
    this.profile = const GamingProfile(),
    this.memories = const [],
    this.messages = const [],
    this.upcoming = const [],
    this.timeline = const [],
    this.error,
    this.notice,
  });

  final AdvisorStatus status;
  final GamingProfile profile;
  final List<GamingMemory> memories;
  final List<AdvisorMessage> messages;
  final List<UpcomingRelease> upcoming;
  final List<TimelineStop> timeline;
  final String? error;
  final String? notice;

  GamingAdvisorState copyWith({
    AdvisorStatus? status,
    GamingProfile? profile,
    List<GamingMemory>? memories,
    List<AdvisorMessage>? messages,
    List<UpcomingRelease>? upcoming,
    List<TimelineStop>? timeline,
    String? error,
    String? notice,
    bool clearNotice = false,
    bool clearError = false,
  }) {
    return GamingAdvisorState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      memories: memories ?? this.memories,
      messages: messages ?? this.messages,
      upcoming: upcoming ?? this.upcoming,
      timeline: timeline ?? this.timeline,
      error: clearError ? null : error ?? this.error,
      notice: clearNotice ? null : notice ?? this.notice,
    );
  }

  @override
  List<Object?> get props => [
    status,
    profile,
    memories,
    messages,
    upcoming,
    timeline,
    error,
    notice,
  ];
}
