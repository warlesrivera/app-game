import 'package:equatable/equatable.dart';

class AmiiboCharacter extends Equatable {
  const AmiiboCharacter({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.gameSeries,
  });

  final String id;
  final String name;
  final String imageUrl;
  final String? gameSeries;

  @override
  List<Object?> get props => [id, name, imageUrl, gameSeries];
}
