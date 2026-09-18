import '../repositories/auth_repository.dart';

class SignUpWithEmail {
  const SignUpWithEmail(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String name,
    required String email,
    required String password,
  }) {
    return _repository.signUpWithEmail(
      name: name,
      email: email,
      password: password,
    );
  }
}
