import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../../../../core/models/announcement_model.dart';
import '../../../../core/providers/core_providers.dart';

class AnnouncementsNotifier extends AsyncNotifier<List<Announcement>> {
  @override
  FutureOr<List<Announcement>> build() async {
    return _fetchAnnouncements();
  }

  Future<List<Announcement>> _fetchAnnouncements({
    bool forceRefresh = false,
  }) async {
    final getAnnouncementsUseCase = ref.read(getAnnouncementsUseCaseProvider);
    final announcements = await getAnnouncementsUseCase.call(
      forceRefresh: forceRefresh,
    );
    await _checkNewAnnouncements(announcements);
    return announcements;
  }

  Future<void> loadAnnouncements({bool forceRefresh = false}) async {
    if (!forceRefresh) state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _fetchAnnouncements(forceRefresh: forceRefresh),
    );
  }

  Future<void> _checkNewAnnouncements(List<Announcement> list) async {
    final prefs = await SharedPreferences.getInstance();
    final lastViewedId = prefs.getString('last_viewed_announcement_id');

    if (list.isNotEmpty && lastViewedId != list.first.id) {
      ref.read(hasNewAnnouncementsProvider.notifier).state = true;
    } else {
      ref.read(hasNewAnnouncementsProvider.notifier).state = false;
    }
  }

  Future<void> markAnnouncementsAsViewed() async {
    state.whenData((list) async {
      if (list.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_viewed_announcement_id', list.first.id);
        ref.read(hasNewAnnouncementsProvider.notifier).state = false;
      }
    });
  }

  Future<void> addAnnouncement(Announcement announcement) async {
    state = await AsyncValue.guard(() async {
      final createAnnouncementUseCase = ref.read(
        createAnnouncementUseCaseProvider,
      );
      final response = await createAnnouncementUseCase.call(announcement);
      final currentList = state.value ?? [];
      final updatedList = [response, ...currentList];
      await _checkNewAnnouncements(updatedList);

      return updatedList;
    });
  }

  Future<void> updateAnnouncement(Announcement announcement) async {
    state = await AsyncValue.guard(() async {
      final updateAnnouncementUseCase = ref.read(
        updateAnnouncementUseCaseProvider,
      );
      final response = await updateAnnouncementUseCase.call(announcement);
      final currentList = state.value ?? [];
      return currentList
          .map((e) => e.id == response.id ? response : e)
          .toList();
    });
  }

  Future<void> deleteAnnouncement(String id) async {
    state = await AsyncValue.guard(() async {
      final deleteAnnouncementUseCase = ref.read(
        deleteAnnouncementUseCaseProvider,
      );
      await deleteAnnouncementUseCase.call(id);
      final currentList = state.value ?? [];
      return currentList.where((e) => e.id != id).toList();
    });
  }
}

class HasNewAnnouncementsNotifier extends Notifier<bool> {
  @override
  bool build() => false;
}

// Providers
final announcementsProvider =
    AsyncNotifierProvider<AnnouncementsNotifier, List<Announcement>>(
      AnnouncementsNotifier.new,
    );

final hasNewAnnouncementsProvider =
    NotifierProvider<HasNewAnnouncementsNotifier, bool>(
      HasNewAnnouncementsNotifier.new,
    );
