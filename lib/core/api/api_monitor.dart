import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Model for API call tracking
class ApiCall {
  final String id;
  final DateTime timestamp;
  final String method;
  final String endpoint;
  final int? statusCode;
  final Duration? duration;
  final Map<String, dynamic>? requestHeaders;
  final dynamic requestBody;
  final dynamic responseBody;
  final String? error;
  final bool isSuccess;

  ApiCall({
    required this.id,
    required this.timestamp,
    required this.method,
    required this.endpoint,
    this.statusCode,
    this.duration,
    this.requestHeaders,
    this.requestBody,
    this.responseBody,
    this.error,
    required this.isSuccess,
  });

  String get statusText {
    if (error != null) return 'ERROR';
    if (statusCode == null) return 'PENDING';
    if (statusCode! >= 200 && statusCode! < 300) return 'SUCCESS';
    if (statusCode! >= 400 && statusCode! < 500) return 'CLIENT ERROR';
    if (statusCode! >= 500) return 'SERVER ERROR';
    return 'UNKNOWN';
  }

  String get displayTime {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

/// API Monitor to track all API calls
class ApiMonitor extends StateNotifier<List<ApiCall>> {
  ApiMonitor() : super([]);

  /// Add a new API call
  void addCall(ApiCall call) {
    state = [call, ...state];

    // Keep only last 100 calls
    if (state.length > 100) {
      state = state.sublist(0, 100);
    }
  }

  /// Clear all calls
  void clearAll() {
    state = [];
  }

  /// Get statistics
  Map<String, dynamic> getStats() {
    if (state.isEmpty) {
      return {
        'total': 0,
        'success': 0,
        'error': 0,
        'avgDuration': 0,
      };
    }

    final successCalls = state.where((c) => c.isSuccess).length;
    final errorCalls = state.where((c) => !c.isSuccess).length;
    final callsWithDuration = state.where((c) => c.duration != null);
    final avgDuration = callsWithDuration.isEmpty
        ? 0
        : callsWithDuration
                .map((c) => c.duration!.inMilliseconds)
                .reduce((a, b) => a + b) /
            callsWithDuration.length;

    return {
      'total': state.length,
      'success': successCalls,
      'error': errorCalls,
      'avgDuration': avgDuration.round(),
    };
  }

  /// Filter calls by method
  List<ApiCall> filterByMethod(String method) {
    return state.where((c) => c.method == method).toList();
  }

  /// Filter calls by status
  List<ApiCall> filterByStatus(bool isSuccess) {
    return state.where((c) => c.isSuccess == isSuccess).toList();
  }
}

/// Provider for API monitor
final apiMonitorProvider =
    StateNotifierProvider<ApiMonitor, List<ApiCall>>((ref) {
  return ApiMonitor();
});

/// Provider for filtered API calls
final filteredApiCallsProvider = Provider.family<List<ApiCall>, ApiCallFilter>(
  (ref, filter) {
    final allCalls = ref.watch(apiMonitorProvider);

    var filtered = allCalls;

    // Filter by method
    if (filter.method != null && filter.method!.isNotEmpty) {
      filtered = filtered.where((c) => c.method == filter.method).toList();
    }

    // Filter by status
    if (filter.statusFilter != null) {
      switch (filter.statusFilter) {
        case StatusFilter.success:
          filtered = filtered.where((c) => c.isSuccess).toList();
          break;
        case StatusFilter.error:
          filtered = filtered.where((c) => !c.isSuccess).toList();
          break;
        case StatusFilter.all:
          break;
        default:
          break;
      }
    }

    // Filter by search query
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      filtered = filtered
          .where((c) =>
              c.endpoint
                  .toLowerCase()
                  .contains(filter.searchQuery!.toLowerCase()) ||
              c.method.toLowerCase().contains(filter.searchQuery!.toLowerCase()))
          .toList();
    }

    return filtered;
  },
);

/// Filter model for API calls
class ApiCallFilter {
  final String? method;
  final StatusFilter? statusFilter;
  final String? searchQuery;

  ApiCallFilter({
    this.method,
    this.statusFilter,
    this.searchQuery,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiCallFilter &&
          runtimeType == other.runtimeType &&
          method == other.method &&
          statusFilter == other.statusFilter &&
          searchQuery == other.searchQuery;

  @override
  int get hashCode =>
      method.hashCode ^ statusFilter.hashCode ^ searchQuery.hashCode;
}

enum StatusFilter {
  all,
  success,
  error,
}
