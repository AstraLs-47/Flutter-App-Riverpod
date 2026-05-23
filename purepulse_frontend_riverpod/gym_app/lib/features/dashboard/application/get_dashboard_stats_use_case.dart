import '../../../core/domain/repositories/i_admin_repository.dart';
import '../../../core/domain/repositories/i_announcement_repository.dart';
import '../../../core/domain/repositories/i_health_repository.dart';
import '../../../core/domain/repositories/i_progress_repository.dart';
import '../../progress/data/health_store.dart';
import '../../workout/data/workout_store.dart';

class GetDashboardStatsUseCase {
  final IHealthRepository _healthRepo;
  final IProgressRepository _progressRepo;
  final IAnnouncementRepository _announcementRepo;
  final IAdminRepository _adminRepo;
  final HealthStore _healthStore;
  final WorkoutStore _workoutStore;

  GetDashboardStatsUseCase({
    required IHealthRepository healthRepo,
    required IProgressRepository progressRepo,
    required IAnnouncementRepository announcementRepo,
    required IAdminRepository adminRepo,
    required HealthStore healthStore,
    required WorkoutStore workoutStore,
  })  : _healthRepo = healthRepo,
        _progressRepo = progressRepo,
        _announcementRepo = announcementRepo,
        _adminRepo = adminRepo,
        _healthStore = healthStore,
        _workoutStore = workoutStore;

  Future<Map<String, dynamic>> call() async {
    // 1. Sync health records → HealthStore (so avgBmi / avgHr are real)
    try {
      final records = await _healthRepo.getHealthRecords();
      _healthStore.setRecords(records);
    } catch (_) {}

    // 2. Sync workout entries → WorkoutStore (so progress counters are real)
    try {
      final entries = await _progressRepo.getWorkoutEntries();
      _workoutStore.setEntries(entries);
    } catch (_) {}

    // 3. Check for any announcements
    bool hasNewAnnouncements = _adminRepo.hasNewAnnouncements;
    try {
      final announcements = await _announcementRepo.getAnnouncements();
      hasNewAnnouncements = announcements.isNotEmpty;
    } catch (_) {}

    return {
      'avgBmi': _healthStore.latestBmi,
      'avgHr': _healthStore.latestHeartRate,
      'totalActivities': _workoutStore.count,
      'hasNewAnnouncements': hasNewAnnouncements,
    };
  }
}
