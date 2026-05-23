import '../../../features/progress/data/models/health_record_model.dart';

/// Contract that [HealthRepository] must implement.
abstract interface class IHealthRepository {
  Future<List<HealthRecord>> getHealthRecords({bool forceRefresh = false});
  Future<HealthRecord?> getLatestMetrics();
  Future<HealthRecord> addHealthRecord(HealthRecord record);
}
