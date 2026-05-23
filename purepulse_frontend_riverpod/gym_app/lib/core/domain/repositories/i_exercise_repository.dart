import '../../../core/models/activity_model.dart';

/// Contract that [ExerciseRepository] must implement.
abstract interface class IExerciseRepository {
  Future<List<Activity>> getExercises({bool forceRefresh = false});
  Future<Activity> createExercise(Activity exercise);
  Future<Activity> updateExercise(Activity exercise);
  Future<void> deleteExercise(String id);
}
