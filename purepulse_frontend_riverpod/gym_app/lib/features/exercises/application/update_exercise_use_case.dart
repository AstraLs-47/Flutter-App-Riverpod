import '../../../core/domain/repositories/i_exercise_repository.dart';
import '../../../core/models/activity_model.dart';

class UpdateExerciseUseCase {
  final IExerciseRepository _exerciseRepository;

  UpdateExerciseUseCase(this._exerciseRepository);

  Future<Activity> call(Activity exercise) {
    return _exerciseRepository.updateExercise(exercise);
  }
}
