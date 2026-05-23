import '../../../core/domain/repositories/i_progress_repository.dart';
import '../data/models/workout_entry_model.dart';

class CreateWorkoutEntryUseCase {
  final IProgressRepository _progressRepository;

  CreateWorkoutEntryUseCase(this._progressRepository);

  Future<WorkoutEntry> call(WorkoutEntry entry) {
    return _progressRepository.createWorkoutEntry(entry);
  }
}
