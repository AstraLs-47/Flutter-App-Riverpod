// Project imports:
import '../../../core/models/activity_model.dart';
import 'exercise_repository.dart';

class ExerciseService {
  final ExerciseRepository _repo = ExerciseRepository();

  Future<List<Activity>> fetchActivities({bool forceRefresh = false}) async {
    return _repo.getExercises(forceRefresh: forceRefresh);
  }

  Future<void> addActivity(Activity activity) async {
    await _repo.createExercise(activity);
  }

  Future<void> updateActivity(Activity activity) async {
    await _repo.updateExercise(activity);
  }

  Future<void> deleteActivity(String id) async {
    await _repo.deleteExercise(id);
  }
}
