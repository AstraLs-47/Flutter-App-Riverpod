import '../../../core/domain/repositories/i_progress_repository.dart';

class DeleteWorkoutEntryUseCase {
  final IProgressRepository _progressRepository;

  DeleteWorkoutEntryUseCase(this._progressRepository);

  Future<void> call(String id) {
    return _progressRepository.deleteWorkoutEntry(id);
  }
}
