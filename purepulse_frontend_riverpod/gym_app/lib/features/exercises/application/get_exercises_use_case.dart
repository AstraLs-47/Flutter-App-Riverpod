import '../../../core/domain/repositories/i_exercise_repository.dart';
import '../../../core/models/activity_model.dart';

class GetExercisesUseCase {
  final IExerciseRepository _exerciseRepository;

  GetExercisesUseCase(this._exerciseRepository);

  Future<List<Activity>> call({bool forceRefresh = false}) {
    return _exerciseRepository.getExercises(forceRefresh: forceRefresh);
  }
}
