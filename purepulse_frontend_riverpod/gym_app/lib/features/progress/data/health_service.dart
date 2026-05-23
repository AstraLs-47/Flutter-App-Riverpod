// Project imports:
import 'health_repository.dart';
import 'health_store.dart';
import 'models/health_record_model.dart';

class HealthService {
  final HealthRepository _repo = HealthRepository();
  final HealthStore _store = HealthStore();

  Future<List<HealthRecord>> fetchHealthRecords({bool forceRefresh = false}) async {
    final records = await _repo.getHealthRecords(forceRefresh: forceRefresh);
    _store.setRecords(records);
    return records;
  }

  Future<HealthRecord?> fetchLatestRecord() async {
    final record = await _repo.getLatestMetrics();
    if (record != null) {
      // Ensure store has this record at the top
      final current = _store.records;
      if (current.isEmpty || current.first.id != record.id) {
        final merged = [record, ...current.where((r) => r.id != record.id)];
        _store.setRecords(merged);
      }
    }
    return record;
  }

  Future<void> addHealthRecord(HealthRecord record) async {
    final newRecord = await _repo.addHealthRecord(record);
    final updated = [newRecord, ..._store.records];
    _store.setRecords(updated);
  }
}
