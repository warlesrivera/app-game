import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();

  @override
  List<Object?> get props => [];
}

final class ConnectivityStarted extends ConnectivityEvent {
  const ConnectivityStarted();
}

final class ConnectivityChanged extends ConnectivityEvent {
  const ConnectivityChanged(this.online);

  final bool online;

  @override
  List<Object?> get props => [online];
}

sealed class ConnectivityState extends Equatable {
  const ConnectivityState();

  bool get isOffline => this is ConnectivityOffline;

  @override
  List<Object?> get props => [];
}

final class ConnectivityOnline extends ConnectivityState {
  const ConnectivityOnline();
}

final class ConnectivityOffline extends ConnectivityState {
  const ConnectivityOffline();
}

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  ConnectivityBloc({Connectivity? connectivity})
    : _connectivity = connectivity,
      super(const ConnectivityOnline()) {
    on<ConnectivityStarted>(_onStarted);
    on<ConnectivityChanged>(_onChanged);
  }

  final Connectivity? _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<void> _onStarted(
    ConnectivityStarted event,
    Emitter<ConnectivityState> emit,
  ) async {
    final connectivity = _connectivity ?? Connectivity();
    try {
      final current = await connectivity.checkConnectivity();
      emit(_fromResults(current));
      await _subscription?.cancel();
      _subscription = connectivity.onConnectivityChanged.listen((results) {
        add(ConnectivityChanged(_isOnline(results)));
      });
    } catch (_) {
      emit(const ConnectivityOnline());
    }
  }

  void _onChanged(
    ConnectivityChanged event,
    Emitter<ConnectivityState> emit,
  ) {
    emit(event.online ? const ConnectivityOnline() : const ConnectivityOffline());
  }

  ConnectivityState _fromResults(List<ConnectivityResult> results) {
    return _isOnline(results)
        ? const ConnectivityOnline()
        : const ConnectivityOffline();
  }

  bool _isOnline(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
