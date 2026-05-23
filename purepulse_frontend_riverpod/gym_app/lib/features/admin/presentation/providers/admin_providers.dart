// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/providers/core_providers.dart';

final adminDashboardStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final getAdminDashboardStatsUseCase = ref.watch(getAdminDashboardStatsUseCaseProvider);
  return getAdminDashboardStatsUseCase.call();
});
