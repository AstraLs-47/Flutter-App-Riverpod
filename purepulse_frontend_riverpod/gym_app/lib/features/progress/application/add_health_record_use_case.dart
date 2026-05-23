import '../../../core/domain/repositories/i_health_repository.dart';
import '../data/models/health_record_model.dart';

class AddHealthRecordUseCase {
  final IHealthRepository _healthRepository;

  AddHealthRecordUseCase(this._healthRepository);

  Future<HealthRecord> call(HealthRecord record) {
    return _healthRepository.addHealthRecord(record);
  }
}
