import 'package:dio/dio.dart';

/// Base exception class for all API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => message;

  /// Factory constructor to create ApiException from DioException
  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkException(
          message: 'Connection timeout. Please check your internet connection.',
        );
      case DioExceptionType.sendTimeout:
        return NetworkException(
          message: 'Request timeout. Please try again.',
        );
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: 'Server response timeout. Please try again.',
        );
      case DioExceptionType.badCertificate:
        return NetworkException(
          message: 'Certificate verification failed.',
        );
      case DioExceptionType.badResponse:
        return _handleBadResponse(error);
      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled.',
        );
      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'No internet connection. Please check your network settings.',
        );
      case DioExceptionType.unknown:
        return NetworkException(
          message: 'An unexpected error occurred. Please try again.',
        );
    }
  }

  /// Handle bad response errors (4xx, 5xx)
  static ApiException _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    // Extract error message from response
    String message = 'An error occurred. Please try again.';
    if (data is Map && data.containsKey('detail')) {
      message = data['detail'].toString();
    }

    switch (statusCode) {
      case 400:
        return BadRequestException(
          message: message,
          statusCode: statusCode,
          data: data,
        );
      case 401:
        return UnauthorizedException(
          message: message.isEmpty ? 'Authentication failed. Please log in again.' : message,
          statusCode: statusCode,
          data: data,
        );
      case 404:
        return NotFoundException(
          message: message.isEmpty ? 'Resource not found.' : message,
          statusCode: statusCode,
          data: data,
        );
      case 500:
      case 502:
      case 503:
        return ServerException(
          message: 'Server error. Please try again later.',
          statusCode: statusCode,
          data: data,
        );
      default:
        return ApiException(
          message: message,
          statusCode: statusCode,
          data: data,
        );
    }
  }
}

/// Exception for network-related errors
class NetworkException extends ApiException {
  NetworkException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

/// Exception for 400 Bad Request
class BadRequestException extends ApiException {
  BadRequestException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

/// Exception for 401 Unauthorized
class UnauthorizedException extends ApiException {
  UnauthorizedException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

/// Exception for 404 Not Found
class NotFoundException extends ApiException {
  NotFoundException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

/// Exception for 500+ Server Errors
class ServerException extends ApiException {
  ServerException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

/// Exception for cache/offline errors
class CacheException extends ApiException {
  CacheException({
    required super.message,
  });
}

/// Exception for JSON parsing errors
class ParseException extends ApiException {
  ParseException({
    super.message = 'Failed to parse server response.',
  });
}
