class Failure implements Exception {
  const Failure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'Failure($code): $message';
}

class AuthFailure extends Failure {
  const AuthFailure(super.code, super.message);
}

class AuthCancelled implements Exception {
  const AuthCancelled();
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.code, super.message);
}
