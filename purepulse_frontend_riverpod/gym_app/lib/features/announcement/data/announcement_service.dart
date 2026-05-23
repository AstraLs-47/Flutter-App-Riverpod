// Project imports:
import '../../../core/models/announcement_model.dart';
import 'announcement_repository.dart';

class AnnouncementService {
  final AnnouncementRepository _repo = AnnouncementRepository();

  Future<List<Announcement>> fetchAnnouncements({bool forceRefresh = false}) async {
    return _repo.getAnnouncements(forceRefresh: forceRefresh);
  }

  Future<void> addAnnouncement(Announcement announcement) async {
    await _repo.createAnnouncement(announcement);
  }

  Future<void> updateAnnouncement(Announcement announcement) async {
    await _repo.updateAnnouncement(announcement);
  }

  Future<void> deleteAnnouncement(String id) async {
    await _repo.deleteAnnouncement(id);
  }
}
