import '../../../core/domain/repositories/i_announcement_repository.dart';
import '../../../core/models/announcement_model.dart';

class GetAnnouncementsUseCase {
  final IAnnouncementRepository _announcementRepository;

  GetAnnouncementsUseCase(this._announcementRepository);

  Future<List<Announcement>> call({bool forceRefresh = false}) {
    return _announcementRepository.getAnnouncements(forceRefresh: forceRefresh);
  }
}
