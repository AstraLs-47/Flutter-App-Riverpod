// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/models/activity_model.dart';
import '../../../../core/providers/core_providers.dart';

class ExercisesNotifier extends AsyncNotifier<List<Activity>> {
  @override
  Future<List<Activity>> build() async {
    final getExercisesUseCase = ref.watch(getExercisesUseCaseProvider);
    return getExercisesUseCase.call();
  }

  Future<void> loadExercises({bool forceRefresh = false}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final getExercisesUseCase = ref.read(getExercisesUseCaseProvider);
      return getExercisesUseCase.call(forceRefresh: forceRefresh);
    });
  }

  Future<void> addExercise(Activity exercise) async {
    state = await AsyncValue.guard(() async {
      final createExerciseUseCase = ref.read(createExerciseUseCaseProvider);
      final response = await createExerciseUseCase.call(exercise);
      return [...state.value ?? [], response];
    });
  }

  Future<void> updateExercise(Activity exercise) async {
    state = await AsyncValue.guard(() async {
      final updateExerciseUseCase = ref.read(updateExerciseUseCaseProvider);
      final response = await updateExerciseUseCase.call(exercise);
      return (state.value ?? [])
          .map((e) => e.id == response.id ? response : e)
          .toList();
    });
  }

  Future<void> deleteExercise(String id) async {
    state = await AsyncValue.guard(() async {
      final deleteExerciseUseCase = ref.read(deleteExerciseUseCaseProvider);
      await deleteExerciseUseCase.call(id);
      return (state.value ?? []).where((e) => e.id != id).toList();
    });
  }
}

class SelectedCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  void setCategory(String category) {
    state = category;
  }
}

// Providers
final exercisesProvider =
    AsyncNotifierProvider<ExercisesNotifier, List<Activity>>(
      ExercisesNotifier.new,
    );

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String>(
      SelectedCategoryNotifier.new,
    );

final filteredExercisesProvider = Provider<AsyncValue<List<Activity>>>((ref) {
  final exercisesAsync = ref.watch(exercisesProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  return exercisesAsync.whenData((exercises) {
    if (selectedCategory == 'All') {
      return exercises;
    }
    return exercises
        .where(
          (e) =>
              e.category.toLowerCase().contains(selectedCategory.toLowerCase()),
        )
        .toList();
  });
});
