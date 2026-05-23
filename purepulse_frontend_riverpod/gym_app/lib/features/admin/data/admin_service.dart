// Project imports:
import '../../../core/models/activity_model.dart';
import '../../../core/models/announcement_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../announcement/data/announcement_repository.dart';
import '../../exercises/data/exercise_repository.dart';
import '../../products/data/product_repository.dart';
import '../../admin/data/admin_repository.dart';

class AdminService {
  final AnnouncementRepository _announcementRepo = AnnouncementRepository();
  final ExerciseRepository _exerciseRepo = ExerciseRepository();
  final ProductRepository _productRepo = ProductRepository();
  final ApiClient _apiClient = ApiClient();

  // ── Announcements ──────────────────────────────────────────────────────────
  Future<List<Announcement>> fetchAnnouncements({
    bool forceRefresh = true,
  }) async {
    return _announcementRepo.getAnnouncements(forceRefresh: forceRefresh);
  }

  Future<void> addAnnouncement(Announcement announcement) async {
    await _announcementRepo.createAnnouncement(announcement);
  }

  Future<void> updateAnnouncement(Announcement announcement) async {
    await _announcementRepo.updateAnnouncement(announcement);
  }

  Future<void> deleteAnnouncement(String id) async {
    await _announcementRepo.deleteAnnouncement(id);
  }

  // ── Admin Dashboard Stats ─────────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchDashboardStats() async {
    try {
      final response =
          await _apiClient.get(ApiEndpoints.adminDashboard)
              as Map<String, dynamic>;

      // Map backend keys to the keys the UI CommandCenterScreen expects
      final categoryRaw = response['categoryDistribution'];
      final Map<String, double> categoryDistribution = {};
      if (categoryRaw is Map) {
        categoryRaw.forEach((k, v) {
          final key = k.toString().trim();
          if (key.isNotEmpty && key.toLowerCase() != 'all') {
            categoryDistribution[key] = (v as num).toDouble();
          }
        });
      }

      final productTypeRaw =
          response['productCategoryDistribution'] ??
          response['productTypeData'];
      final Map<String, double> productDistribution = {};
      if (productTypeRaw is Map) {
        productTypeRaw.forEach((k, v) {
          final key = k.toString().trim();
          if (key.isNotEmpty && key.toLowerCase() != 'all') {
            productDistribution[key] = (v as num).toDouble();
          }
        });
      }

      final engagementRaw = response['engagementData'];
      List<double> engagementData = [];
      if (engagementRaw is List) {
        engagementData = engagementRaw
            .map((v) => (v as num).toDouble())
            .toList();
      }

      final recentRaw = response['recentActivities'];
      List<Map<String, String>> recentActivities = [];
      if (recentRaw is List) {
        recentActivities = recentRaw.map((item) {
          final m = item as Map<String, dynamic>;
          return {
            'title': (m['title'] ?? '').toString(),
            'subtitle': (m['subtitle'] ?? m['description'] ?? '').toString(),
          };
        }).toList();
      }

      return {
        'avgBmi': ((response['avgBmi'] ?? 0.0) as num).toDouble(),
        'avgHr': ((response['avgHr'] ?? 0.0) as num).toDouble(),
        // Backend key is totalExercises; UI reads totalActivities
        'totalActivities':
            (response['totalExercises'] ?? response['totalActivities'] ?? 0)
                as int,
        'totalProducts': (response['totalProducts'] ?? 0) as int,
        // Backend key is totalAnnouncements; UI reads announcementsCount
        'announcementsCount':
            (response['totalAnnouncements'] ??
                    response['announcementsCount'] ??
                    0)
                as int,
        'productDistribution': productDistribution,
        'categoryDistribution': categoryDistribution,
        'engagementData': engagementData,
        'recentActivities': recentActivities,
      };
    } catch (_) {
      // Fallback: derive stats from local cache / repos
      final List<Activity> exercises = await _exerciseRepo.getExercises();
      final products = await _productRepo.getProducts();
      final announcements = await _announcementRepo.getAnnouncements();

      final sortedExercises = List<Activity>.from(exercises)
        ..sort((a, b) => b.id.compareTo(a.id));

      final Map<String, double> catDist = {};
      for (final Activity e in exercises) {
        final category = e.category.trim();
        if (category.isNotEmpty && category.toLowerCase() != 'all') {
          catDist[category] = (catDist[category] ?? 0) + 1;
        }
      }

      return {
        'avgBmi': 0.0,
        'avgHr': 0.0,
        'totalActivities': exercises.length,
        'totalProducts': products.length,
        'announcementsCount': announcements.length,
        'productDistribution': AdminRepository().productCategoryDistribution,
        'categoryDistribution': catDist,
        'engagementData': <double>[2.0, 6.0, 8.0, 3.0, 4.0, 7.0, 3.0],
        'recentActivities': sortedExercises
            .take(4)
            .whereType<Activity>()
            .map<Map<String, String>>((e) {
              final Activity activity = e;
              return {
                'title': activity.title,
                'subtitle': '${activity.category} • Just now',
              };
            })
            .toList(),
      };
    }
  }
}
