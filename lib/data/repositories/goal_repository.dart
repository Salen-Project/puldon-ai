import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/goal_model.dart';

/// Repository for goal-related API calls
class GoalRepository {
  final ApiClient _apiClient;

  GoalRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get all goals
  Future<List<GoalModel>> getGoals() async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiEndpoints.goals,
      useCache: true,
    );
    return response
        .map((json) => GoalModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get goal detail with contribution history
  Future<GoalDetailModel> getGoalDetail(String goalId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.goalDetail(goalId),
      useCache: true,
    );
    return GoalDetailModel.fromJson(response);
  }

  /// Create a new goal
  Future<CreateGoalResponse> createGoal(CreateGoalRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.goals,
      data: request.toJson(),
    );
    return CreateGoalResponse.fromJson(response);
  }

  /// Update an existing goal
  Future<UpdateGoalResponse> updateGoal(
    String goalId,
    UpdateGoalRequest request,
  ) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.updateGoal(goalId),
      data: request.toJson(),
    );
    return UpdateGoalResponse.fromJson(response);
  }

  /// Delete a goal
  Future<DeleteGoalResponse> deleteGoal(String goalId) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      ApiEndpoints.deleteGoal(goalId),
    );
    return DeleteGoalResponse.fromJson(response);
  }

  /// Update goal progress (legacy endpoint)
  Future<Map<String, dynamic>> updateGoalProgress(
    String goalId,
    double currentAmount,
  ) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.updateGoalProgress(goalId),
      queryParameters: {'current_amount': currentAmount},
    );
    return response;
  }
}

/// Provider for GoalRepository
final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return GoalRepository(apiClient: apiClient);
});

/// Provider to get all goals
final goalsProvider = FutureProvider<List<GoalModel>>((ref) async {
  final repository = ref.watch(goalRepositoryProvider);
  return await repository.getGoals();
});

/// Provider to get goal detail
final goalDetailProvider = FutureProvider.family<GoalDetailModel, String>(
  (ref, goalId) async {
    final repository = ref.watch(goalRepositoryProvider);
    return await repository.getGoalDetail(goalId);
  },
);
