// Project imports:
import 'models/health_record_model.dart';

class HealthStore {
  HealthStore._internal();
  static final HealthStore _instance = HealthStore._internal();
  factory HealthStore() => _instance;

  final List<HealthRecord> _records = [];

  List<HealthRecord> get records => List.unmodifiable(_records);

  HealthRecord? get latestRecord => _records.isEmpty ? null : _records.first;

  /// Bulk-replace all records (used after fetching from backend).
  void setRecords(List<HealthRecord> newRecords) {
    _records.clear();
    _records.addAll(newRecords);
    _records.sort((a, b) => b.date.compareTo(a.date));
  }

  void addRecord(HealthRecord record) {
    _records.insert(0, record);
  }

  // Helper to get latest value or 0
  double get latestSystolic => latestRecord?.systolic ?? 0;
  double get latestDiastolic => latestRecord?.diastolic ?? 0;
  double get latestHeartRate => latestRecord?.heartRate ?? 0;
  double get latestBloodSugar => latestRecord?.bloodSugar ?? 0;
  double get latestWeight => latestRecord?.weight ?? 0;
  double get latestHeight => latestRecord?.height ?? 0;
  double get latestBmi => latestRecord?.bmi ?? 0;
}
