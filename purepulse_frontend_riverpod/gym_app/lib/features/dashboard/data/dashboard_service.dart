// Project imports:
import '../../../core/domain/repositories/i_admin_repository.dart';
import '../../../core/domain/repositories/i_announcement_repository.dart';
import '../../../core/domain/repositories/i_health_repository.dart';
import '../../../core/domain/repositories/i_progress_repository.dart';
import '../../admin/data/admin_repository.dart';
import '../../announcement/data/announcement_repository.dart';
import '../../progress/data/health_repository.dart';
import '../../progress/data/health_store.dart';
import '../../workout/data/progress_repository.dart';
import '../../workout/data/workout_store.dart';

class DashboardService {
  final IHealthRepository _healthRepo;
  final IProgressRepository _progressRepo;
  final IAnnouncementRepository _announcementRepo;
  final HealthStore _healthStore;
  final WorkoutStore _workoutStore;
  final IAdminRepository _db;

  DashboardService({
    IHealthRepository? healthRepo,
    IProgressRepository? progressRepo,
    IAnnouncementRepository? announcementRepo,
    HealthStore? healthStore,
    WorkoutStore? workoutStore,
    IAdminRepository? db,
  })  : _healthRepo = healthRepo ?? HealthRepository(),
        _progressRepo = progressRepo ?? ProgressRepository(),
        _announcementRepo = announcementRepo ?? AnnouncementRepository(),
        _healthStore = healthStore ?? HealthStore(),
        _workoutStore = workoutStore ?? WorkoutStore(),
        _db = db ?? AdminRepository();

  Future<Map<String, dynamic>> fetchDashboardStats() async {
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
    bool hasNewAnnouncements = _db.hasNewAnnouncements;
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
