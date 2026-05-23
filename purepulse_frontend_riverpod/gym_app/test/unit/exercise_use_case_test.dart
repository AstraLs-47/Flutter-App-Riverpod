import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/domain/repositories/i_exercise_repository.dart';
import 'package:gym_app/core/models/activity_model.dart';
import 'package:gym_app/features/exercises/application/get_exercises_use_case.dart';
import 'package:gym_app/features/exercises/application/create_exercise_use_case.dart';
import 'package:gym_app/features/exercises/application/update_exercise_use_case.dart';
import 'package:gym_app/features/exercises/application/delete_exercise_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockExerciseRepository extends Mock implements IExerciseRepository {}

void main() {
  late MockExerciseRepository mockExerciseRepository;
  late GetExercisesUseCase getExercisesUseCase;
  late CreateExerciseUseCase createExerciseUseCase;
  late UpdateExerciseUseCase updateExerciseUseCase;
  late DeleteExerciseUseCase deleteExerciseUseCase;

  final testActivity = Activity(
    id: '1',
    title: 'Push Up',
    description: 'Standard chest push up',
    image: 'pushup.png',
    category: 'Chest',
  );

  setUpAll(() {
    registerFallbackValue(Activity(
      id: '',
      title: '',
      description: '',
      image: '',
      category: '',
    ));
  });

  setUp(() {
    mockExerciseRepository = MockExerciseRepository();
    getExercisesUseCase = GetExercisesUseCase(mockExerciseRepository);
    createExerciseUseCase = CreateExerciseUseCase(mockExerciseRepository);
    updateExerciseUseCase = UpdateExerciseUseCase(mockExerciseRepository);
    deleteExerciseUseCase = DeleteExerciseUseCase(mockExerciseRepository);
  });

  group('GetExercisesUseCase', () {
    test('should return list of activities from repository', () async {
      when(() => mockExerciseRepository.getExercises(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => [testActivity]);

      final result = await getExercisesUseCase.call(forceRefresh: true);

      expect(result, [testActivity]);
      verify(() => mockExerciseRepository.getExercises(forceRefresh: true)).called(1);
    });
  });

  group('CreateExerciseUseCase', () {
    test('should return created activity from repository', () async {
      when(() => mockExerciseRepository.createExercise(any()))
          .thenAnswer((_) async => testActivity);

      final result = await createExerciseUseCase.call(testActivity);

      expect(result, testActivity);
      verify(() => mockExerciseRepository.createExercise(testActivity)).called(1);
    });
  });

  group('UpdateExerciseUseCase', () {
    test('should return updated activity from repository', () async {
      when(() => mockExerciseRepository.updateExercise(any()))
          .thenAnswer((_) async => testActivity);

      final result = await updateExerciseUseCase.call(testActivity);

      expect(result, testActivity);
      verify(() => mockExerciseRepository.updateExercise(testActivity)).called(1);
    });
  });

  group('DeleteExerciseUseCase', () {
    test('should complete successfully when repository delete succeeds', () async {
      when(() => mockExerciseRepository.deleteExercise(any()))
          .thenAnswer((_) async {});

      await deleteExerciseUseCase.call('1');

      verify(() => mockExerciseRepository.deleteExercise('1')).called(1);
    });
  });
}
