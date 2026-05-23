// Project imports:
import '../../../core/data/database_helper.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/domain/repositories/i_progress_repository.dart';
import 'models/workout_entry_model.dart';

class ProgressRepository implements IProgressRepository {
  final ApiClient _apiClient;
  final DatabaseHelper _dbHelper;

  ProgressRepository({ApiClient? apiClient, DatabaseHelper? dbHelper})
    : _apiClient = apiClient ?? ApiClient(),
      _dbHelper = dbHelper ?? DatabaseHelper();

  String _normalizeIntensity(String? intensity) {
    final normalized = intensity?.trim().toLowerCase();
    if (normalized == 'light' ||
        normalized == 'moderate' ||
        normalized == 'intense') {
      return normalized!;
    }
    return 'moderate';
  }

  String _displayIntensity(String? intensity) {
    switch (_normalizeIntensity(intensity)) {
      case 'light':
        return 'Light';
      case 'intense':
        return 'Intense';
      case 'moderate':
      default:
        return 'Moderate';
    }
  }

  WorkoutEntry _mapJsonToEntry(Map<String, dynamic> json) {
    final name =
        json['exerciseName'] ??
        json['exercise_name'] ??
        json['title'] ??
        json['exercise'] ??
        'Workout';
    final weightVal = json['weight']?.toString() ?? '0';
    final setsVal = json['sets']?.toString() ?? '0';
    final repsVal = json['reps']?.toString() ?? '0';
    final rawDur =
        (json['durationMinutes'] ??
                json['duration_minutes'] ??
                json['duration'] ??
                '0')
            .toString();
    final durVal = rawDur.contains('MIN') ? rawDur : '$rawDur MIN';
    final dateStr =
        json['entryDate'] ??
        json['entry_date'] ??
        json['date'] ??
        DateTime.now().toIso8601String().split('T').first;

    return WorkoutEntry(
      id: json['id'].toString(),
      title: name,
      date: dateStr,
      duration: durVal,
      exercise: name,
      intensity: _displayIntensity(json['intensity']?.toString()),
      weight: weightVal,
      sets: setsVal,
      reps: repsVal,
      calories: json['calories']?.toString() ?? '',
      achievement: json['achievement']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> _mapEntryToDb(WorkoutEntry entry) {
    final cleanDuration = entry.duration.replaceAll(RegExp(r'\D'), '');
    return {
      'id': entry.id,
      'exercise_name': entry.exercise,
      'entry_date': entry.date,
      'duration_minutes': int.tryParse(cleanDuration) ?? 0,
      'sets': int.tryParse(entry.sets) ?? 0,
      'reps': int.tryParse(entry.reps) ?? 0,
      'weight': double.tryParse(entry.weight) ?? 0.0,
      'intensity': entry.intensity,
      'notes': entry.notes ?? '',
      'achievement': entry.achievement ?? '',
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  Future<List<WorkoutEntry>> getWorkoutEntries({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cachedRows = await _dbHelper.queryAll('progress_entries');
      if (cachedRows.isNotEmpty) {
        final entries = cachedRows.map((row) => _mapJsonToEntry(row)).toList();
        entries.sort((a, b) => b.date.compareTo(a.date));
        return entries;
      }
    }

    final response = await _apiClient.get(ApiEndpoints.progress);
    final List<dynamic> entriesJson = response is Map
        ? (response['entries'] ?? [])
        : response;
    final entries = entriesJson
        .map((item) => _mapJsonToEntry(item as Map<String, dynamic>))
        .toList();

    // Cache in SQLite
    await _dbHelper.clearTable('progress_entries');
    final rows = entries.map((e) => _mapEntryToDb(e)).toList();
    await _dbHelper.insertAll('progress_entries', rows);

    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  Future<WorkoutEntry> createWorkoutEntry(WorkoutEntry entry) async {
    final cleanDuration = entry.duration.replaceAll(RegExp(r'\D'), '');
    final response = await _apiClient.post(
      ApiEndpoints.progress,
      body: {
        'exerciseName': entry.exercise,
        'entryDate': entry.date,
        'durationMinutes': int.tryParse(cleanDuration) ?? 0,
        'sets': int.tryParse(entry.sets) ?? 0,
        'reps': int.tryParse(entry.reps) ?? 0,
        'weight': double.tryParse(entry.weight) ?? 0.0,
        'intensity': _normalizeIntensity(entry.intensity),
        'notes': entry.notes,
        'achievement': entry.achievement,
      },
    );

    final newEntry = _mapJsonToEntry(response);
    await _dbHelper.insert('progress_entries', _mapEntryToDb(newEntry));
    return newEntry;
  }

  Future<WorkoutEntry> updateWorkoutEntry(WorkoutEntry entry) async {
    final cleanDuration = entry.duration.replaceAll(RegExp(r'\D'), '');
    final response = await _apiClient.put(
      ApiEndpoints.progressId(entry.id),
      body: {
        'exerciseName': entry.exercise,
        'entryDate': entry.date,
        'durationMinutes': int.tryParse(cleanDuration) ?? 0,
        'sets': int.tryParse(entry.sets) ?? 0,
        'reps': int.tryParse(entry.reps) ?? 0,
        'weight': double.tryParse(entry.weight) ?? 0.0,
        'intensity': _normalizeIntensity(entry.intensity),
        'notes': entry.notes,
        'achievement': entry.achievement,
      },
    );

    final updatedEntry = _mapJsonToEntry(response);
    await _dbHelper.insert('progress_entries', _mapEntryToDb(updatedEntry));
    return updatedEntry;
  }

  Future<void> deleteWorkoutEntry(String id) async {
    await _apiClient.delete(ApiEndpoints.progressId(id));
    await _dbHelper.delete('progress_entries', id);
  }

  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.stats);
      return response as Map<String, dynamic>;
    } catch (_) {
      // Calculate local stats from SQLite cache
      final entries = await getWorkoutEntries();
      final totalMinutes = entries.fold<int>(
        0,
        (sum, e) =>
            sum + (int.tryParse(e.duration.replaceAll(RegExp(r'\D'), '')) ?? 0),
      );
      return {
        'totalEntries': entries.length,
        'totalMinutes': totalMinutes,
        'exercisesUsed': entries.map((e) => e.exercise).toSet().length,
      };
    }
  }
}
