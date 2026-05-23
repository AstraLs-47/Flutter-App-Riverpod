import '../../../core/domain/repositories/i_health_repository.dart';
import '../data/models/health_record_model.dart';

class GetHealthRecordsUseCase {
  final IHealthRepository _healthRepository;

  GetHealthRecordsUseCase(this._healthRepository);

  Future<List<HealthRecord>> call({bool forceRefresh = false}) {
    return _healthRepository.getHealthRecords(forceRefresh: forceRefresh);
  }
}
