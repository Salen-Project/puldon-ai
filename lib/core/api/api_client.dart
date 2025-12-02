import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:uuid/uuid.dart';

import '../errors/api_exception.dart';
import '../utils/token_manager.dart';
import 'api_endpoints.dart';
import 'api_monitor.dart';

/// API Client for making HTTP requests with Dio
class ApiClient {
  late final Dio _dio;
  final TokenManager _tokenManager;
  final Logger _logger = Logger();
  CacheStore? _cacheStore;
  final ApiMonitor? _apiMonitor;
  final Uuid _uuid = const Uuid();

  ApiClient({
    required TokenManager tokenManager,
    Dio? dio,
    ApiMonitor? apiMonitor,
  })  : _tokenManager = tokenManager,
        _apiMonitor = apiMonitor {
    _dio = dio ?? Dio();
    _initializeDioSync();
    // Initialize cache store asynchronously without blocking
    _initializeCacheStore();
  }

  /// Initialize Dio with base configuration and interceptors (synchronous part)
  void _initializeDioSync() {
    // Configure HTTP client adapter for HTTPS with self-signed certificate
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      // Bypass SSL verification for self-signed certificate on specific host
      // Only allow certificate bypass for our API server
      client.badCertificateCallback = (cert, host, port) {
        return host == '151.245.140.91';
      };
      // Set connection timeout to match or exceed Dio timeout
      // This is the low-level TCP connection timeout (different from Dio's timeout)
      client.connectionTimeout = const Duration(seconds: 30);
      return client;
    };

    _dio.options = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15), // Connection timeout
      receiveTimeout: const Duration(seconds: 30), // Default receive timeout (auth, dashboard, etc.)
      sendTimeout: const Duration(seconds: 30), // Default send timeout
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) {
        // Accept all status codes to handle them manually
        return status != null && status < 500;
      },
    );

    // Add interceptors immediately (cache will be added later)
    _addInterceptors();
  }

  /// Initialize Hive cache store for offline support (non-blocking)
  Future<void> _initializeCacheStore() async {
    try {
      final dir = await getTemporaryDirectory();
      _cacheStore = HiveCacheStore(dir.path);
      
      // Add cache interceptor after cache store is ready
      if (_cacheStore != null) {
        _dio.interceptors.add(
          DioCacheInterceptor(
            options: CacheOptions(
              store: _cacheStore!,
              policy: CachePolicy.request,
              hitCacheOnErrorExcept: [401, 403], // Don't cache auth errors
              maxStale: const Duration(days: 7),
              priority: CachePriority.normal,
              cipher: null,
              keyBuilder: CacheOptions.defaultCacheKeyBuilder,
              allowPostMethod: false,
            ),
          ),
        );
      }
    } catch (e) {
      _logger.w('Failed to initialize cache store: $e');
    }
  }

  /// Add all necessary interceptors
  void _addInterceptors() {
    // API Monitoring interceptor - Track all API calls
    if (_apiMonitor != null) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            // Create API call entry
            final callId = _uuid.v4();
            options.extra['callId'] = callId;
            options.extra['startTime'] = DateTime.now();

            _apiMonitor.addCall(
              ApiCall(
                id: callId,
                timestamp: DateTime.now(),
                method: options.method,
                endpoint: options.path,
                requestHeaders: options.headers,
                requestBody: options.data,
                isSuccess: false, // Will be updated on response
              ),
            );

            return handler.next(options);
          },
          onResponse: (response, handler) {
            final callId = response.requestOptions.extra['callId'] as String?;
            final startTime =
                response.requestOptions.extra['startTime'] as DateTime?;

            if (callId != null && startTime != null) {
              final duration = DateTime.now().difference(startTime);

              // Update the call with response data
              _apiMonitor.addCall(
                ApiCall(
                  id: callId,
                  timestamp: startTime,
                  method: response.requestOptions.method,
                  endpoint: response.requestOptions.path,
                  statusCode: response.statusCode,
                  duration: duration,
                  requestHeaders: response.requestOptions.headers,
                  requestBody: response.requestOptions.data,
                  responseBody: response.data,
                  isSuccess: response.statusCode != null &&
                      response.statusCode! >= 200 &&
                      response.statusCode! < 300,
                ),
              );
            }

            return handler.next(response);
          },
          onError: (error, handler) {
            final callId = error.requestOptions.extra['callId'] as String?;
            final startTime =
                error.requestOptions.extra['startTime'] as DateTime?;

            if (callId != null && startTime != null) {
              final duration = DateTime.now().difference(startTime);

              // Update the call with error data
              _apiMonitor.addCall(
                ApiCall(
                  id: callId,
                  timestamp: startTime,
                  method: error.requestOptions.method,
                  endpoint: error.requestOptions.path,
                  statusCode: error.response?.statusCode,
                  duration: duration,
                  requestHeaders: error.requestOptions.headers,
                  requestBody: error.requestOptions.data,
                  responseBody: error.response?.data,
                  error: error.message,
                  isSuccess: false,
                ),
              );
            }

            return handler.next(error);
          },
        ),
      );
    }

    // Auth interceptor - Add JWT token to requests
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get token from storage
          final token = await _tokenManager.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 Unauthorized - Token expired
          if (error.response?.statusCode == 401) {
            _logger.w('Token expired or invalid. Clearing authentication.');
            await _tokenManager.clearAll();
          }
          return handler.next(error);
        },
      ),
    );

    // Note: Cache interceptor is added asynchronously in _initializeCacheStore()

    // Logging interceptor (only in debug mode)
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  /// GET request
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool useCache = true,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options?.copyWith(
          extra: useCache ? {'cache': true} : null,
        ),
        cancelToken: cancelToken,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      _logger.e('Unexpected error in GET request: $e');
      throw ApiException(message: 'An unexpected error occurred.');
    }
  }

  /// POST request
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      _logger.e('Unexpected error in POST request: $e');
      throw ApiException(message: 'An unexpected error occurred.');
    }
  }

  /// PUT request
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      _logger.e('Unexpected error in PUT request: $e');
      throw ApiException(message: 'An unexpected error occurred.');
    }
  }

  /// PATCH request
  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      _logger.e('Unexpected error in PATCH request: $e');
      throw ApiException(message: 'An unexpected error occurred.');
    }
  }

  /// DELETE request
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      _logger.e('Unexpected error in DELETE request: $e');
      throw ApiException(message: 'An unexpected error occurred.');
    }
  }

  /// Handle response and extract data
  T _handleResponse<T>(Response response) {
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      return response.data as T;
    } else {
      // This shouldn't happen due to validateStatus, but handle it anyway
      throw ApiException(
        message: 'Request failed with status: ${response.statusCode}',
        statusCode: response.statusCode,
        data: response.data,
      );
    }
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    if (_cacheStore != null) {
      await _cacheStore!.clean();
      _logger.i('Cache cleared successfully');
    }
  }

  /// Close the Dio client
  void close() {
    _dio.close();
  }
}

/// Provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenManager = ref.watch(tokenManagerProvider);
  final apiMonitor = ref.watch(apiMonitorProvider.notifier);
  return ApiClient(
    tokenManager: tokenManager,
    apiMonitor: apiMonitor,
  );
});
