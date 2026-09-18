import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.age,
    required this.avatarId,
  });

  final String id;
  final String email;
  final String name;
  final int age;
  final String avatarId;

  @override
  List<Object?> get props => [id, email, name, age, avatarId];
}
