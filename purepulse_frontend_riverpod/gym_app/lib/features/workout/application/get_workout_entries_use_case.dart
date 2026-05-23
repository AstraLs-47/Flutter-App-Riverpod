import '../../../core/domain/repositories/i_progress_repository.dart';
import '../data/models/workout_entry_model.dart';

class GetWorkoutEntriesUseCase {
  final IProgressRepository _progressRepository;

  GetWorkoutEntriesUseCase(this._progressRepository);

  Future<List<WorkoutEntry>> call({bool forceRefresh = false}) {
    return _progressRepository.getWorkoutEntries(forceRefresh: forceRefresh);
  }
}
