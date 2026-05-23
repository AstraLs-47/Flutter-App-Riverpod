import '../../../features/workout/data/models/workout_entry_model.dart';

/// Contract that [ProgressRepository] must implement.
abstract interface class IProgressRepository {
  Future<List<WorkoutEntry>> getWorkoutEntries({bool forceRefresh = false});
  Future<WorkoutEntry> createWorkoutEntry(WorkoutEntry entry);
  Future<WorkoutEntry> updateWorkoutEntry(WorkoutEntry entry);
  Future<void> deleteWorkoutEntry(String id);
  Future<Map<String, dynamic>> getStats();
}
