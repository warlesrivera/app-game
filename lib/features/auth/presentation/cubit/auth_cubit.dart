import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email.dart';
import '../../domain/usecases/update_avatar_url.dart';
import '../../domain/usecases/watch_auth_state.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required WatchAuthState watchAuthState,
    required SignInWithEmail signInWithEmail,
    required SignUpWithEmail signUpWithEmail,
    required SignInWithGoogle signInWithGoogle,
    required SignOut signOut,
    UpdateAvatarUrl? updateAvatarUrl,
  }) : signInWithEmailUseCase = signInWithEmail,
       signUpWithEmailUseCase = signUpWithEmail,
       signInWithGoogleUseCase = signInWithGoogle,
       signOutUseCase = signOut,
       _updateAvatarUrl = updateAvatarUrl,
       super(const AuthInitial()) {
    _subscription = watchAuthState().listen(
      _onAuthUser,
      onError: (Object error) {
        emit(AuthError(_messageFrom(error)));
      },
    );
  }

  final SignInWithEmail signInWithEmailUseCase;
  final SignUpWithEmail signUpWithEmailUseCase;
  final SignInWithGoogle signInWithGoogleUseCase;
  final SignOut signOutUseCase;
  final UpdateAvatarUrl? _updateAvatarUrl;
  StreamSubscription<AppUser?>? _subscription;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _run(() {
      return signInWithEmailUseCase(email: email, password: password);
    });
  }

  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) {
    return _run(() {
      return signUpWithEmailUseCase(
        name: name,
        email: email,
        password: password,
      );
    });
  }

  Future<void> signInWithGoogle() {
    return _run(signInWithGoogleUseCase.call);
  }

  Future<void> updateAvatar(String avatarUrl) async {
    final current = state;
    final update = _updateAvatarUrl;
    if (current is! AuthAuthenticated || update == null) {
      return;
    }
    await update(uid: current.user.id, avatarUrl: avatarUrl);
    if (isClosed) {
      return;
    }
    emit(AuthAuthenticated(current.user.copyWith(avatarUrl: avatarUrl)));
  }

  Future<void> signOut() async {
    emit(const AuthLoading());
    try {
      await signOutUseCase();
      emit(const AuthUnauthenticated());
    } on AuthCancelled {
      emit(const AuthUnauthenticated());
    } catch (error) {
      emit(AuthError(_messageFrom(error)));
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    emit(const AuthLoading());
    try {
      await action();
    } on AuthCancelled {
      emit(const AuthUnauthenticated());
    } catch (error) {
      emit(AuthError(_messageFrom(error)));
    }
  }

  void _onAuthUser(AppUser? user) {
    if (user == null) {
      emit(const AuthUnauthenticated());
      return;
    }
    emit(AuthAuthenticated(user));
  }

  String _messageFrom(Object error) {
    if (error is Failure) {
      return error.message;
    }
    return 'Ocurrió un error inesperado.';
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
