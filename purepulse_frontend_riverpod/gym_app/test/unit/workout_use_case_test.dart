import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/domain/repositories/i_progress_repository.dart';
import 'package:gym_app/features/workout/data/models/workout_entry_model.dart';
import 'package:gym_app/features/workout/application/get_workout_entries_use_case.dart';
import 'package:gym_app/features/workout/application/create_workout_entry_use_case.dart';
import 'package:gym_app/features/workout/application/update_workout_entry_use_case.dart';
import 'package:gym_app/features/workout/application/delete_workout_entry_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockProgressRepository extends Mock implements IProgressRepository {}

void main() {
  late MockProgressRepository mockProgressRepository;
  late GetWorkoutEntriesUseCase getWorkoutEntriesUseCase;
  late CreateWorkoutEntryUseCase createWorkoutEntryUseCase;
  late UpdateWorkoutEntryUseCase updateWorkoutEntryUseCase;
  late DeleteWorkoutEntryUseCase deleteWorkoutEntryUseCase;

  final testEntry = WorkoutEntry(
    id: '1',
    title: 'Workout 1',
    date: '2026-05-23',
    duration: '45 MIN',
    exercise: 'Running',
    intensity: 'Moderate',
    weight: '0',
    sets: '1',
    reps: '1',
  );

  setUpAll(() {
    registerFallbackValue(WorkoutEntry(
      id: '',
      title: '',
      date: '',
      duration: '',
      exercise: '',
      intensity: '',
      weight: '',
      sets: '',
      reps: '',
    ));
  });

  setUp(() {
    mockProgressRepository = MockProgressRepository();
    getWorkoutEntriesUseCase = GetWorkoutEntriesUseCase(mockProgressRepository);
    createWorkoutEntryUseCase = CreateWorkoutEntryUseCase(mockProgressRepository);
    updateWorkoutEntryUseCase = UpdateWorkoutEntryUseCase(mockProgressRepository);
    deleteWorkoutEntryUseCase = DeleteWorkoutEntryUseCase(mockProgressRepository);
  });

  group('GetWorkoutEntriesUseCase', () {
    test('should return list of workout entries from repository', () async {
      when(() => mockProgressRepository.getWorkoutEntries(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => [testEntry]);

      final result = await getWorkoutEntriesUseCase.call(forceRefresh: true);

      expect(result, [testEntry]);
      verify(() => mockProgressRepository.getWorkoutEntries(forceRefresh: true)).called(1);
    });
  });

  group('CreateWorkoutEntryUseCase', () {
    test('should return created workout entry from repository', () async {
      when(() => mockProgressRepository.createWorkoutEntry(any()))
          .thenAnswer((_) async => testEntry);

      final result = await createWorkoutEntryUseCase.call(testEntry);

      expect(result, testEntry);
      verify(() => mockProgressRepository.createWorkoutEntry(testEntry)).called(1);
    });
  });

  group('UpdateWorkoutEntryUseCase', () {
    test('should return updated workout entry from repository', () async {
      when(() => mockProgressRepository.updateWorkoutEntry(any()))
          .thenAnswer((_) async => testEntry);

      final result = await updateWorkoutEntryUseCase.call(testEntry);

      expect(result, testEntry);
      verify(() => mockProgressRepository.updateWorkoutEntry(testEntry)).called(1);
    });
  });

  group('DeleteWorkoutEntryUseCase', () {
    test('should complete successfully when repository delete succeeds', () async {
      when(() => mockProgressRepository.deleteWorkoutEntry(any()))
          .thenAnswer((_) async {});

      await deleteWorkoutEntryUseCase.call('1');

      verify(() => mockProgressRepository.deleteWorkoutEntry('1')).called(1);
    });
  });
}
