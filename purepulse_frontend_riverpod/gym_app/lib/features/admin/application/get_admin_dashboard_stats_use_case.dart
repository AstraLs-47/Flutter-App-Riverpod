import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class GetAdminDashboardStatsUseCase {
  final ApiClient _apiClient;

  GetAdminDashboardStatsUseCase(this._apiClient);

  Future<Map<String, dynamic>> call() async {
    final response = await _apiClient.get(ApiEndpoints.adminDashboard);
    final stats = Map<String, dynamic>.from(response as Map);
    
    final catDist = stats['categoryDistribution'];
    if (catDist is Map) {
      stats['categoryDistribution'] = catDist.map((k, v) => MapEntry(k.toString(), (v as num).toDouble()));
    } else {
      stats['categoryDistribution'] = <String, double>{};
    }

    final prodType = stats['productTypeData'];
    if (prodType is List) {
      stats['productTypeData'] = prodType.map((v) => (v as num).toDouble()).toList();
    } else {
      stats['productTypeData'] = <double>[0, 0, 0, 0];
    }

    final engagement = stats['engagementData'];
    if (engagement is List) {
      stats['engagementData'] = engagement.map((v) => (v as num).toDouble()).toList();
    } else {
      stats['engagementData'] = <double>[0, 0, 0, 0, 0, 0, 0];
    }

    return stats;
  }
}
