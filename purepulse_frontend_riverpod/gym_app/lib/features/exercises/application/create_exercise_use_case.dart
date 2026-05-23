import '../../../core/domain/repositories/i_exercise_repository.dart';
import '../../../core/models/activity_model.dart';

class CreateExerciseUseCase {
  final IExerciseRepository _exerciseRepository;

  CreateExerciseUseCase(this._exerciseRepository);

  Future<Activity> call(Activity exercise) {
    return _exerciseRepository.createExercise(exercise);
  }
}
