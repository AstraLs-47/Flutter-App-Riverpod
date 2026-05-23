import '../../../core/domain/repositories/i_announcement_repository.dart';
import '../../../core/models/announcement_model.dart';

class CreateAnnouncementUseCase {
  final IAnnouncementRepository _announcementRepository;

  CreateAnnouncementUseCase(this._announcementRepository);

  Future<Announcement> call(Announcement announcement) {
    return _announcementRepository.createAnnouncement(announcement);
  }
}
