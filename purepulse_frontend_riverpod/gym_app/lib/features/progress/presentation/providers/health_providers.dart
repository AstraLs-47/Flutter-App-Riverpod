// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/providers/core_providers.dart';
import '../../data/models/health_record_model.dart';

class HealthNotifier extends AsyncNotifier<List<HealthRecord>> {
  @override
  Future<List<HealthRecord>> build() async {
    final getHealthRecordsUseCase = ref.read(getHealthRecordsUseCaseProvider);
    return getHealthRecordsUseCase.call();
  }

  Future<void> loadHealthRecords({bool forceRefresh = false}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final getHealthRecordsUseCase = ref.read(getHealthRecordsUseCaseProvider);
      return getHealthRecordsUseCase.call(forceRefresh: forceRefresh);
    });
  }

  Future<void> addHealthRecord(HealthRecord record) async {
    final addHealthRecordUseCase = ref.read(addHealthRecordUseCaseProvider);
    final response = await addHealthRecordUseCase.call(record);
    final updatedList = [response, ...state.value ?? []];
    updatedList.sort((a, b) => b.date.compareTo(a.date));
    state = AsyncValue.data(updatedList);
  }
}

// Providers
final healthRecordsProvider = AsyncNotifierProvider<HealthNotifier, List<HealthRecord>>(() {
  return HealthNotifier();
});

final latestHealthRecordProvider = Provider<HealthRecord?>((ref) {
  final healthAsync = ref.watch(healthRecordsProvider);
  return healthAsync.when(
    data: (records) => records.isNotEmpty ? records.first : null,
    loading: () => null,
    error: (_, _) => null,
  );
});
