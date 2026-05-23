import '../../../core/domain/repositories/i_exercise_repository.dart';

class DeleteExerciseUseCase {
  final IExerciseRepository _exerciseRepository;

  DeleteExerciseUseCase(this._exerciseRepository);

  Future<void> call(String id) {
    return _exerciseRepository.deleteExercise(id);
  }
}
