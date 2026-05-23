import '../../../core/domain/repositories/i_announcement_repository.dart';

class DeleteAnnouncementUseCase {
  final IAnnouncementRepository _announcementRepository;

  DeleteAnnouncementUseCase(this._announcementRepository);

  Future<void> call(String id) {
    return _announcementRepository.deleteAnnouncement(id);
  }
}
