// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../core/data/database_helper.dart';
import '../../../core/models/activity_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/domain/repositories/i_exercise_repository.dart';

class ExerciseRepository implements IExerciseRepository {
  final ApiClient _apiClient;
  final DatabaseHelper _dbHelper;

  ExerciseRepository({ApiClient? apiClient, DatabaseHelper? dbHelper})
    : _apiClient = apiClient ?? ApiClient(),
      _dbHelper = dbHelper ?? DatabaseHelper();

  String get _serverBaseUrl {
    final uri = Uri.parse(ApiEndpoints.baseUrl);
    return uri.replace(path: '').toString();
  }

  String _normalizeImageUrl(String path) {
    if (path.isEmpty) {
      return '';
    }
    if (path.startsWith('http') ||
        path.startsWith('assets/') ||
        path.startsWith('blob:')) {
      return path;
    }
    if (path.startsWith('/uploads/')) {
      return '$_serverBaseUrl$path';
    }
    if (path.startsWith('uploads/')) {
      return '$_serverBaseUrl/$path';
    }
    if (path.startsWith('/') ||
        path.contains(':\\') ||
        path.startsWith('file://')) {
      return path;
    }
    return '$_serverBaseUrl/uploads/$path';
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  Activity _mapJsonToActivity(Map<String, dynamic> json) {
    String rawCategory =
        (json['category'] ??
                json['categoryName'] ??
                json['category_name'] ??
                '')
            .toString();
    rawCategory = rawCategory.trim();

    // Safety: 'All' is a UI filter, not a valid exercise category for storage
    if (rawCategory.toLowerCase() == 'all') {
      rawCategory = '';
    }

    return Activity(
      id: (json['id'] ?? '').toString(),
      title: json['title'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      image: _normalizeImageUrl(
        json['image'] ?? json['imageUrl'] ?? json['image_url'] ?? '',
      ),
      // accept various DB/API key styles including category_name
      category: _capitalize(rawCategory),
      duration: json['duration'] ?? '',
      warmup: json['warmup'] ?? '',
      mainWorkout: json['mainWorkout'] ?? json['main_workout'] ?? '',
      rest: json['rest'] ?? '',
    );
  }

  Map<String, dynamic> _mapActivityToDb(Activity activity) {
    return {
      'id': activity.id,
      'name': activity.title,
      'description': activity.description,
      'image_url': activity.image,
      'category_name': activity.category,
      'duration': activity.duration,
      'warmup': activity.warmup,
      'main_workout': activity.mainWorkout,
      'rest': activity.rest,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  Future<List<Activity>> getExercises({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cachedRows = await _dbHelper.queryAll('exercises');
      if (cachedRows.isNotEmpty) {
        return cachedRows.map((row) => _mapJsonToActivity(row)).toList();
      }
    }

    final List<dynamic> response = await _apiClient.get(
      ApiEndpoints.activities,
    );
    final exercises = response
        .map((item) => _mapJsonToActivity(item as Map<String, dynamic>))
        .toList();

    // Cache in SQLite
    await _dbHelper.clearTable('exercises');
    final rows = exercises.map((e) => _mapActivityToDb(e)).toList();
    await _dbHelper.insertAll('exercises', rows);

    return exercises;
  }

  Future<Activity> createExercise(Activity exercise) async {
    final response = await _apiClient.post(
      ApiEndpoints.activities,
      body: {
        'title': exercise.title,
        'description': exercise.description,
        'category': exercise.category,
        'category_id': exercise.categoryId,
        'image': exercise.image,
        'duration': exercise.duration,
        'warmup': exercise.warmup,
        'mainWorkout': exercise.mainWorkout,
        'rest': exercise.rest,
      },
    );

    final newExercise = _mapJsonToActivity(response);
    await _dbHelper.insert('exercises', _mapActivityToDb(newExercise));
    return newExercise;
  }

  Future<Activity> updateExercise(Activity exercise) async {
    final response = await _apiClient.put(
      ApiEndpoints.activity(exercise.id),
      body: {
        'title': exercise.title,
        'description': exercise.description,
        'category': exercise.category,
        'category_id': exercise.categoryId,
        'image': exercise.image,
        'duration': exercise.duration,
        'warmup': exercise.warmup,
        'mainWorkout': exercise.mainWorkout,
        'rest': exercise.rest,
      },
    );

    final updatedExercise = _mapJsonToActivity(response);
    await _dbHelper.insert('exercises', _mapActivityToDb(updatedExercise));
    return updatedExercise;
  }

  Future<void> deleteExercise(String id) async {
    if (id.isEmpty) return;
    try {
      await _apiClient.delete(ApiEndpoints.activity(id));
    } catch (e) {
      debugPrint('Exercise API deletion failed: $e');
    }
    await _dbHelper.delete('exercises', id);
  }
}
