// Project imports:
import '../../../core/data/database_helper.dart';
import '../../../core/models/announcement_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/domain/repositories/i_announcement_repository.dart';

class AnnouncementRepository implements IAnnouncementRepository {
  final ApiClient _apiClient;
  final DatabaseHelper _dbHelper;

  AnnouncementRepository({
    ApiClient? apiClient,
    DatabaseHelper? dbHelper,
  })  : _apiClient = apiClient ?? ApiClient(),
        _dbHelper = dbHelper ?? DatabaseHelper();

  Announcement _mapJsonToAnnouncement(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> _mapAnnouncementToDb(Announcement announcement) {
    return {
      'id': announcement.id,
      'title': announcement.title,
      'description': announcement.description,
      'date': announcement.date,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  Future<List<Announcement>> getAnnouncements({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cachedRows = await _dbHelper.queryAll('announcements');
      if (cachedRows.isNotEmpty) {
        return cachedRows.map((row) => _mapJsonToAnnouncement(row)).toList();
      }
    }

    final List<dynamic> response = await _apiClient.get(ApiEndpoints.announcements);
    final announcements = response.map((item) => _mapJsonToAnnouncement(item as Map<String, dynamic>)).toList();

    // Cache in SQLite
    await _dbHelper.clearTable('announcements');
    final rows = announcements.map((a) => _mapAnnouncementToDb(a)).toList();
    await _dbHelper.insertAll('announcements', rows);

    return announcements;
  }

  Future<Announcement> createAnnouncement(Announcement announcement) async {
    final response = await _apiClient.post(
      ApiEndpoints.announcements,
      body: {
        'title': announcement.title,
        'description': announcement.description,
        'date': announcement.date,
      },
    );

    final newAnnouncement = _mapJsonToAnnouncement(response);
    await _dbHelper.insert('announcements', _mapAnnouncementToDb(newAnnouncement));
    return newAnnouncement;
  }

  Future<Announcement> updateAnnouncement(Announcement announcement) async {
    final response = await _apiClient.put(
      ApiEndpoints.announcement(announcement.id),
      body: {
        'title': announcement.title,
        'description': announcement.description,
        'date': announcement.date,
      },
    );

    final updatedAnnouncement = _mapJsonToAnnouncement(response);
    await _dbHelper.insert('announcements', _mapAnnouncementToDb(updatedAnnouncement));
    return updatedAnnouncement;
  }

  Future<void> deleteAnnouncement(String id) async {
    await _apiClient.delete(ApiEndpoints.announcement(id));
    await _dbHelper.delete('announcements', id);
  }
}
