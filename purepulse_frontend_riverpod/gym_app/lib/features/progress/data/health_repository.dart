// Project imports:
import '../../../core/data/database_helper.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import 'models/health_record_model.dart';

import '../../../core/domain/repositories/i_health_repository.dart';

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    return parsed ?? 0.0;
  }
  return 0.0;
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) {
    final parsed = int.tryParse(value);
    return parsed ?? 0;
  }
  return 0;
}

class HealthRepository implements IHealthRepository {
  final ApiClient _apiClient;
  final DatabaseHelper _dbHelper;

  HealthRepository({ApiClient? apiClient, DatabaseHelper? dbHelper})
    : _apiClient = apiClient ?? ApiClient(),
      _dbHelper = dbHelper ?? DatabaseHelper();

  HealthRecord _mapJsonToRecord(Map<String, dynamic> json) {
    final dateStr =
        json['date'] ??
        json['measurementDate'] ??
        DateTime.now().toIso8601String();
    return HealthRecord(
      id: json['id'].toString(),
      systolic: _parseDouble(
        json['systolic'] ??
            json['bloodPressureSystolic'] ??
            json['blood_pressure_systolic'] ??
            0.0,
      ),
      diastolic: _parseDouble(
        json['diastolic'] ??
            json['bloodPressureDiastolic'] ??
            json['blood_pressure_diastolic'] ??
            0.0,
      ),
      heartRate: _parseDouble(
        json['heartRate'] ??
            json['restingHeartRate'] ??
            json['resting_heart_rate'] ??
            json['heart_rate'] ??
            0.0,
      ),
      bloodSugar: _parseDouble(
        json['bloodSugar'] ?? json['blood_sugar'] ?? 0.0,
      ),
      weight: _parseDouble(json['weight'] ?? 0.0),
      height: _parseDouble(json['height'] ?? 0.0),
      bmi: _parseDouble(json['bmi'] ?? 0.0),
      date: DateTime.parse(dateStr),
    );
  }

  Map<String, dynamic> _mapRecordToDb(HealthRecord record) {
    return {
      'id': record.id,
      'blood_pressure_systolic': record.systolic.toInt(),
      'blood_pressure_diastolic': record.diastolic.toInt(),
      'resting_heart_rate': record.heartRate.toInt(),
      'blood_sugar': record.bloodSugar,
      'weight': record.weight,
      'height': record.height,
      'bmi': record.bmi,
      'date': record.date.toIso8601String(),
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  Future<List<HealthRecord>> getHealthRecords({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cachedRows = await _dbHelper.queryAll('health_metrics');
      if (cachedRows.isNotEmpty) {
        final records = cachedRows.map((row) => _mapJsonToRecord(row)).toList();
        // Sort by date descending
        records.sort((a, b) => b.date.compareTo(a.date));
        return records;
      }
    }

    final response = await _apiClient.get(ApiEndpoints.healthRecords);
    // backend returns { entries: [...], pagination: {...} } or list of items depending on endpoint.
    // Looking at healthController listHistory, it returns res.json(result); which includes result.entries.
    final List<dynamic> entries = response is Map
        ? (response['entries'] ?? [])
        : response;
    final records = entries
        .map((item) => _mapJsonToRecord(item as Map<String, dynamic>))
        .toList();

    // Cache in SQLite
    await _dbHelper.clearTable('health_metrics');
    final rows = records.map((r) => _mapRecordToDb(r)).toList();
    await _dbHelper.insertAll('health_metrics', rows);

    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  Future<HealthRecord?> getLatestMetrics() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.healthLatest);
      if (response == null) return null;
      final record = _mapJsonToRecord(response);
      await _dbHelper.insert('health_metrics', _mapRecordToDb(record));
      return record;
    } catch (_) {
      // Return latest from SQLite cache
      final records = await getHealthRecords();
      if (records.isNotEmpty) {
        return records.first;
      }
      return null;
    }
  }

  Future<HealthRecord> addHealthRecord(HealthRecord record) async {
    final response = await _apiClient.post(
      ApiEndpoints.healthRecords,
      body: {
        'weight': record.weight,
        'height': record.height,
        'bodyFatPercentage': 0, // Not present in model, but expected by backend
        'muscleMass': 0,
        'waterPercentage': 0,
        'restingHeartRate': record.heartRate.toInt(),
        'bloodPressureSystolic': record.systolic.toInt(),
        'bloodPressureDiastolic': record.diastolic.toInt(),
        'bloodSugar': record.bloodSugar,
        'measurementDate': record.date.toIso8601String().split('T').first,
      },
    );

    final newRecord = _mapJsonToRecord(response);
    await _dbHelper.insert('health_metrics', _mapRecordToDb(newRecord));
    return newRecord;
  }
}
