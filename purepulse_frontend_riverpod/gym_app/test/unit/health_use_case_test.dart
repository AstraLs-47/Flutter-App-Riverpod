import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/domain/repositories/i_health_repository.dart';
import 'package:gym_app/features/progress/data/models/health_record_model.dart';
import 'package:gym_app/features/progress/application/get_health_records_use_case.dart';
import 'package:gym_app/features/progress/application/add_health_record_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockHealthRepository extends Mock implements IHealthRepository {}

void main() {
  late MockHealthRepository mockHealthRepository;
  late GetHealthRecordsUseCase getHealthRecordsUseCase;
  late AddHealthRecordUseCase addHealthRecordUseCase;

  final testRecord = HealthRecord(
    id: '1',
    systolic: 120,
    diastolic: 80,
    heartRate: 72,
    bloodSugar: 95,
    weight: 78,
    height: 180,
    bmi: 24.1,
    date: DateTime(2026, 5, 23),
  );

  setUpAll(() {
    registerFallbackValue(HealthRecord(
      id: '',
      systolic: 0,
      diastolic: 0,
      heartRate: 0,
      bloodSugar: 0,
      weight: 0,
      height: 0,
      bmi: 0,
      date: DateTime(2026, 1, 1),
    ));
  });

  setUp(() {
    mockHealthRepository = MockHealthRepository();
    getHealthRecordsUseCase = GetHealthRecordsUseCase(mockHealthRepository);
    addHealthRecordUseCase = AddHealthRecordUseCase(mockHealthRepository);
  });

  group('GetHealthRecordsUseCase', () {
    test('should return list of health records from repository', () async {
      when(() => mockHealthRepository.getHealthRecords(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => [testRecord]);

      final result = await getHealthRecordsUseCase.call(forceRefresh: true);

      expect(result, [testRecord]);
      verify(() => mockHealthRepository.getHealthRecords(forceRefresh: true)).called(1);
    });
  });

  group('AddHealthRecordUseCase', () {
    test('should return added health record from repository', () async {
      when(() => mockHealthRepository.addHealthRecord(any()))
          .thenAnswer((_) async => testRecord);

      final result = await addHealthRecordUseCase.call(testRecord);

      expect(result, testRecord);
      verify(() => mockHealthRepository.addHealthRecord(testRecord)).called(1);
    });
  });
}
