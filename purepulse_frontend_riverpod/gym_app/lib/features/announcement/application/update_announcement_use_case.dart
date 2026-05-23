import '../../../core/domain/repositories/i_announcement_repository.dart';
import '../../../core/models/announcement_model.dart';

class UpdateAnnouncementUseCase {
  final IAnnouncementRepository _announcementRepository;

  UpdateAnnouncementUseCase(this._announcementRepository);

  Future<Announcement> call(Announcement announcement) {
    return _announcementRepository.updateAnnouncement(announcement);
  }
}
