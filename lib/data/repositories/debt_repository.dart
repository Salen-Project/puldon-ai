import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/debt_model.dart';

/// Repository for debt-related API calls
class DebtRepository {
  final ApiClient _apiClient;

  DebtRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Add a new debt
  Future<AddDebtResponse> addDebt(AddDebtRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.debts,
      data: request.toJson(),
    );
    return AddDebtResponse.fromJson(response);
  }

  /// Get debt summary for a specific month
  Future<DebtSummaryModel> getDebtSummary({String? month}) async {
    final queryParameters = <String, dynamic>{};
    if (month != null) {
      queryParameters['month'] = month;
    }

    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.debtsSummary,
      queryParameters: queryParameters,
      useCache: true,
    );
    return DebtSummaryModel.fromJson(response);
  }
}

/// Provider for DebtRepository
final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DebtRepository(apiClient: apiClient);
});

/// Provider to get debt summary
final debtSummaryProvider = FutureProvider.family<DebtSummaryModel, String?>(
  (ref, month) async {
    final repository = ref.watch(debtRepositoryProvider);
    return await repository.getDebtSummary(month: month);
  },
);
