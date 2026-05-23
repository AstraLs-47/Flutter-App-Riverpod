import '../../../core/models/announcement_model.dart';

/// Contract that [AnnouncementRepository] must implement.
abstract interface class IAnnouncementRepository {
  Future<List<Announcement>> getAnnouncements({bool forceRefresh = false});
  Future<Announcement> createAnnouncement(Announcement announcement);
  Future<Announcement> updateAnnouncement(Announcement announcement);
  Future<void> deleteAnnouncement(String id);
}
