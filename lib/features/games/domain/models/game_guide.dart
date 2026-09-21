import 'package:equatable/equatable.dart';

class GameGuide extends Equatable {
  const GameGuide({
    this.summary,
    this.sourceLabel,
    this.wikiUrl,
    this.walkthroughUrl,
    this.ignUrl,
    this.redditUrl,
  });

  final String? summary;
  final String? sourceLabel;
  final String? wikiUrl;
  final String? walkthroughUrl;
  final String? ignUrl;
  final String? redditUrl;

  bool get hasText => summary != null && summary!.trim().isNotEmpty;

  bool get hasLinks =>
      wikiUrl != null ||
      walkthroughUrl != null ||
      ignUrl != null ||
      redditUrl != null;

  bool get isEmpty => !hasText && !hasLinks;

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'sourceLabel': sourceLabel,
      'wikiUrl': wikiUrl,
      'walkthroughUrl': walkthroughUrl,
      'ignUrl': ignUrl,
      'redditUrl': redditUrl,
    };
  }

  factory GameGuide.fromJson(Map<String, dynamic> json) {
    return GameGuide(
      summary: json['summary'] as String?,
      sourceLabel: json['sourceLabel'] as String?,
      wikiUrl: json['wikiUrl'] as String?,
      walkthroughUrl: json['walkthroughUrl'] as String?,
      ignUrl: json['ignUrl'] as String?,
      redditUrl: json['redditUrl'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    summary,
    sourceLabel,
    wikiUrl,
    walkthroughUrl,
    ignUrl,
    redditUrl,
  ];
}
