import '../models/library_status.dart';
import '../repositories/library_repository.dart';

class SetGameStatus {
  const SetGameStatus(this._repository);

  final LibraryRepository _repository;

  Future<void> call({required String gameId, required LibraryStatus status}) {
    return _repository.setStatus(gameId: gameId, status: status);
  }
}
