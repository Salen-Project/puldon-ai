import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/expense_model.dart';

/// Repository for expense-related API calls
class ExpenseRepository {
  final ApiClient _apiClient;

  ExpenseRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Add a new expense
  Future<AddExpenseResponse> addExpense(AddExpenseRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.expenses,
      data: request.toJson(),
    );
    return AddExpenseResponse.fromJson(response);
  }

  /// Get expenses with optional filtering
  Future<List<ExpenseModel>> getExpenses({
    String? category,
    int limit = 100,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (category != null) {
      queryParameters['category'] = category;
    }
    queryParameters['limit'] = limit;

    final response = await _apiClient.get<List<dynamic>>(
      ApiEndpoints.expenses,
      queryParameters: queryParameters,
      useCache: true,
    );

    return response
        .map((json) => ExpenseModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get spending summary for a specified period
  Future<SpendingSummaryModel> getSpendingSummary({
    String period = 'last_30d',
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.expensesSummary,
      queryParameters: {'period': period},
      useCache: true,
    );
    return SpendingSummaryModel.fromJson(response);
  }
}

/// Provider for ExpenseRepository
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ExpenseRepository(apiClient: apiClient);
});

/// Provider to get expenses list
final expensesProvider = FutureProvider.family<List<ExpenseModel>, ExpenseFilter>(
  (ref, filter) async {
    final repository = ref.watch(expenseRepositoryProvider);
    return await repository.getExpenses(
      category: filter.category,
      limit: filter.limit,
    );
  },
);

/// Provider to get spending summary
final spendingSummaryProvider = FutureProvider.family<SpendingSummaryModel, String>(
  (ref, period) async {
    final repository = ref.watch(expenseRepositoryProvider);
    return await repository.getSpendingSummary(period: period);
  },
);

/// Filter model for expenses
class ExpenseFilter {
  final String? category;
  final int limit;

  ExpenseFilter({
    this.category,
    this.limit = 100,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseFilter &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          limit == other.limit;

  @override
  int get hashCode => category.hashCode ^ limit.hashCode;
}
