import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manager for handling JWT tokens securely
class TokenManager {
  static const String _tokenKey = 'jwt_token';
  static const String _phoneKey = 'user_phone';

  final FlutterSecureStorage _storage;

  TokenManager({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Save JWT token securely
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Get stored JWT token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Check if token exists
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Delete JWT token
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Save user phone number
  Future<void> savePhone(String phone) async {
    await _storage.write(key: _phoneKey, value: phone);
  }

  /// Get stored phone number
  Future<String?> getPhone() async {
    return await _storage.read(key: _phoneKey);
  }

  /// Delete phone number
  Future<void> deletePhone() async {
    await _storage.delete(key: _phoneKey);
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

/// Provider for TokenManager
final tokenManagerProvider = Provider<TokenManager>((ref) {
  return TokenManager();
});

/// Provider to check if user is authenticated
final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final tokenManager = ref.watch(tokenManagerProvider);
  return await tokenManager.hasToken();
});
