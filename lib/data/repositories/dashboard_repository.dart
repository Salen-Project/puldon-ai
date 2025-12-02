import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/dashboard_model.dart';

/// Repository for dashboard-related API calls
class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  /// Get dashboard overview
  Future<DashboardModel> getDashboard() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.dashboard,
      useCache: true,
    );
    return DashboardModel.fromJson(response);
  }
}

/// Provider for DashboardRepository
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DashboardRepository(apiClient: apiClient);
});

/// Provider to get dashboard data
final dashboardProvider = FutureProvider<DashboardModel>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return await repository.getDashboard();
});
