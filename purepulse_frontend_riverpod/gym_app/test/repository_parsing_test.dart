import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/data/database_helper.dart';
import 'package:gym_app/core/network/api_client.dart';
import 'package:gym_app/features/progress/data/health_repository.dart';
import 'package:gym_app/features/progress/data/models/health_record_model.dart';
import 'package:gym_app/features/workout/data/models/workout_entry_model.dart';
import 'package:gym_app/features/workout/data/progress_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mocktail/mocktail.dart';

class MockDatabaseHelper extends Mock implements DatabaseHelper {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockDatabaseHelper mockDbHelper;

  setUpAll(() {
    registerFallbackValue(<Map<String, dynamic>>[]);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockDbHelper = MockDatabaseHelper();
    
    // Default stubbing for mock DB helper
    when(() => mockDbHelper.clearTable(any())).thenAnswer((_) async {});
    when(() => mockDbHelper.insertAll(any(), any())).thenAnswer((_) async {});
    when(() => mockDbHelper.insert(any(), any())).thenAnswer((_) async {});
    when(() => mockDbHelper.delete(any(), any())).thenAnswer((_) async {});
  });

  test('addHealthRecord parses backend numeric strings into doubles', () async {
    final mockClient = MockClient((request) async {
      expect(request.url.path, '/api/health');
      expect(jsonDecode(request.body), {
        'weight': 95.0,
        'height': 180.0,
        'bodyFatPercentage': 0,
        'muscleMass': 0,
        'waterPercentage': 0,
        'restingHeartRate': 65,
        'bloodPressureSystolic': 120,
        'bloodPressureDiastolic': 80,
        'bloodSugar': 105.5,
        'measurementDate': '2026-05-23',
      });

      return http.Response(
        jsonEncode({
          'id': 8,
          'weight': '95.00',
          'height': '180.00',
          'bmi': '29.32',
          'restingHeartRate': 65,
          'bloodPressureSystolic': 120,
          'bloodPressureDiastolic': 80,
          'bloodSugar': '105.50',
          'measurementDate': '2026-05-23',
        }),
        201,
        headers: {'Content-Type': 'application/json'},
      );
    });

    final repo = HealthRepository(
      apiClient: ApiClient(client: mockClient),
      dbHelper: mockDbHelper,
    );

    final saved = await repo.addHealthRecord(
      HealthRecord(
        id: 'temp-id',
        systolic: 120,
        diastolic: 80,
        heartRate: 65,
        bloodSugar: 105.5,
        weight: 95.0,
        height: 180.0,
        bmi: 29.32,
        date: DateTime(2026, 5, 23),
      ),
    );

    expect(saved.weight, 95.0);
    expect(saved.height, 180.0);
    expect(saved.bloodSugar, 105.5);
  });

  test(
    'createWorkoutEntry normalizes intensity before sending to the backend',
    () async {
      String? body;
      final mockClient = MockClient((request) async {
        body = request.body;
        return http.Response(
          jsonEncode({
            'id': 15,
            'exerciseName': 'Bench Press',
            'entryDate': '2026-05-23',
            'durationMinutes': 40,
            'sets': 3,
            'reps': 10,
            'weight': '80.50',
            'intensity': 'moderate',
            'notes': 'verified',
            'achievement': 'PB',
          }),
          201,
          headers: {'Content-Type': 'application/json'},
        );
      });

      final repo = ProgressRepository(
        apiClient: ApiClient(client: mockClient),
        dbHelper: mockDbHelper,
      );

      final saved = await repo.createWorkoutEntry(
        WorkoutEntry(
          id: 'workout-temp',
          title: 'Bench Press',
          date: '2026-05-23',
          duration: '40 MIN',
          exercise: 'Bench Press',
          intensity: 'Moderate',
          weight: '80.5',
          sets: '3',
          reps: '10',
          calories: '0',
          achievement: 'PB',
          notes: 'verified',
        ),
      );

      expect(saved.intensity, 'Moderate');
      expect(jsonDecode(body!)['intensity'], 'moderate');
    },
  );
}
