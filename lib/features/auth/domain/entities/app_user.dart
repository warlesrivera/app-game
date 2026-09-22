import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
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

  String get dicebearUrl {
    final seed = Uri.encodeQueryComponent(
      email.isNotEmpty ? email : (name.isNotEmpty ? name : id),
    );
    return 'https://api.dicebear.com/9.x/pixel-art/svg?seed=$seed';
  }

  bool get hasCustomAvatar {
    final url = avatarUrl?.trim();
    return url != null && url.isNotEmpty;
  }

  AppUser copyWith({
    String? name,
    String? avatarId,
    String? avatarUrl,
    bool clearAvatarUrl = false,
  }) {
    return AppUser(
      id: id,
      email: email,
      name: name ?? this.name,
      age: age,
      avatarId: avatarId ?? this.avatarId,
      avatarUrl: clearAvatarUrl ? null : avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [id, email, name, age, avatarId, avatarUrl];
}
