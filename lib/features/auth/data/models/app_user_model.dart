import '../../domain/entities/app_user.dart';

class AppUserModel {
  const AppUserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.age,
    required this.avatarId,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String name;
  final int age;
  final String avatarId;
  final String? avatarUrl;

  factory AppUserModel.fromMap(String id, Map<String, dynamic> data) {
    return AppUserModel(
      id: id,
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? '',
      age: (data['age'] as num?)?.toInt() ?? 0,
      avatarId: data['avatarId'] as String? ?? 'avatar_01',
      avatarUrl: data['avatarUrl'] as String?,
    );
  }

  AppUser toEntity() {
    return AppUser(
      id: id,
      email: email,
      name: name,
      age: age,
      avatarId: avatarId,
      avatarUrl: avatarUrl,
    );
  }
}
