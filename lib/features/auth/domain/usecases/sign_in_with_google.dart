import '../repositories/auth_repository.dart';

class SignInWithGoogle {
  const SignInWithGoogle(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.signInWithGoogle();
}
