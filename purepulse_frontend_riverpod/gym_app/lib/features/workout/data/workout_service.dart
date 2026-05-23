// Project imports:
import 'models/workout_entry_model.dart';
import 'progress_repository.dart';
import 'workout_store.dart';

class WorkoutService {
  final ProgressRepository _repo = ProgressRepository();
  final WorkoutStore _store = WorkoutStore();

  Future<List<WorkoutEntry>> fetchWorkoutLogs({
    bool forceRefresh = false,
  }) async {
    final entries = await _repo.getWorkoutEntries(forceRefresh: forceRefresh);
    _store.setEntries(entries);
    return entries;
  }

  Future<void> logWorkout(WorkoutEntry entry) async {
    await _store.addEntry(entry);
  }

  Future<void> updateWorkout(WorkoutEntry entry) async {
    await _store.updateEntry(entry);
  }

  Future<void> deleteWorkout(String id) async {
    await _store.removeEntry(id);
  }

  Future<Map<String, dynamic>> fetchStats() async {
    return _repo.getStats();
  }
}
