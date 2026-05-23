import '../../../core/domain/repositories/i_progress_repository.dart';
import '../data/models/workout_entry_model.dart';

class UpdateWorkoutEntryUseCase {
  final IProgressRepository _progressRepository;

  UpdateWorkoutEntryUseCase(this._progressRepository);

  Future<WorkoutEntry> call(WorkoutEntry entry) {
    return _progressRepository.updateWorkoutEntry(entry);
  }
}
