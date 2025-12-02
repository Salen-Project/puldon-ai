import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/utils/token_manager.dart';
import '../models/user_model.dart';

/// Repository for authentication-related API calls
class AuthRepository {
  final ApiClient _apiClient;
  final TokenManager _tokenManager;

  AuthRepository({
    required ApiClient apiClient,
    required TokenManager tokenManager,
  })  : _apiClient = apiClient,
        _tokenManager = tokenManager;

  /// Sign up a new user
  Future<SignUpResponse> signUp(SignUpRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.signUp,
      data: request.toJson(),
    );
    return SignUpResponse.fromJson(response);
  }

  /// Request OTP for sign in
  Future<OtpResponse> requestOtp(String phoneNumber) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.requestOtp,
      data: OtpRequest(phoneNumber: phoneNumber).toJson(),
    );
    return OtpResponse.fromJson(response);
  }

  /// Verify OTP and get access token
  Future<TokenResponse> verifyOtp(String phoneNumber, String otp) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.verifyOtp,
      data: VerifyOtpRequest(
        phoneNumber: phoneNumber,
        otp: otp,
      ).toJson(),
    );

    final tokenResponse = TokenResponse.fromJson(response);

    // Save token and phone number
    await _tokenManager.saveToken(tokenResponse.accessToken);
    await _tokenManager.savePhone(phoneNumber);

    return tokenResponse;
  }

  /// Get current user profile
  Future<UserModel> getProfile() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.getProfile,
      useCache: true,
    );
    return UserModel.fromJson(response);
  }

  /// Update user profile
  Future<UpdateProfileResponse> updateProfile(
      UpdateProfileRequest request) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.updateProfile,
      data: request.toJson(),
    );
    return UpdateProfileResponse.fromJson(response);
  }

  /// Request OTP to update phone number
  Future<OtpResponse> requestPhoneUpdateOtp(String newPhoneNumber) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.requestPhoneUpdateOtp,
      data: {'new_phone_number': newPhoneNumber},
    );
    return OtpResponse.fromJson(response);
  }

  /// Verify OTP and update phone number
  Future<Map<String, dynamic>> verifyPhoneUpdateOtp(
    String newPhoneNumber,
    String otp,
  ) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.verifyPhoneUpdateOtp,
      data: {
        'new_phone_number': newPhoneNumber,
        'otp': otp,
      },
    );

    // Update stored phone number
    if (response['success'] == true) {
      await _tokenManager.savePhone(newPhoneNumber);
    }

    return response;
  }

  /// Sign out - clear all stored data
  Future<void> signOut() async {
    await _tokenManager.clearAll();
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _tokenManager.hasToken();
  }
}

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final tokenManager = ref.watch(tokenManagerProvider);
  return AuthRepository(
    apiClient: apiClient,
    tokenManager: tokenManager,
  );
});

/// Provider to get current user profile
final currentUserProvider = FutureProvider<UserModel>((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return await authRepository.getProfile();
});
