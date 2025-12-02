import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/api_exception.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

/// Authentication state
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? error;
  final String? phoneNumber; // For OTP flow
  final String? otpCode; // For development mode

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.phoneNumber,
    this.otpCode,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? error,
    String? phoneNumber,
    String? otpCode,
    bool clearError = false,
    bool clearOtp = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: clearError ? null : (error ?? this.error),
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otpCode: clearOtp ? null : (otpCode ?? this.otpCode),
    );
  }
}

/// Authentication state provider
class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthStateNotifier(this._authRepository) : super(const AuthState()) {
    // Defer auth check to next event loop to avoid blocking UI
    Future.microtask(() => _checkAuthStatus());
  }

  /// Check if user is already authenticated
  Future<void> _checkAuthStatus() async {
    try {
      // First check if token exists (fast, local check)
      final isAuth = await _authRepository.isAuthenticated();
      if (!isAuth) {
        // No token, user is not authenticated
        if (mounted) {
          state = state.copyWith(isAuthenticated: false);
        }
        return;
      }

      // Token exists, try to fetch profile with timeout
      try {
        final user = await _authRepository.getProfile().timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            throw Exception('Profile fetch timeout');
          },
        );
        
        // Only update state if still mounted
        if (mounted) {
          state = state.copyWith(
            isAuthenticated: true,
            user: user,
          );
        }
      } catch (e) {
        // If profile fetch fails, clear auth but don't block
        try {
          await _authRepository.signOut();
        } catch (_) {
          // Ignore cleanup errors
        }
        
        if (mounted) {
          state = state.copyWith(isAuthenticated: false);
        }
      }
    } catch (e) {
      // If anything fails, assume not authenticated
      if (mounted) {
        state = state.copyWith(isAuthenticated: false);
      }
    }
  }

  /// Sign up a new user
  Future<bool> signUp({
    required String phoneNumber,
    required String fullName,
    String? email,
    String? gender,
    String? dateOfBirth,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final request = SignUpRequest(
        phoneNumber: phoneNumber,
        fullName: fullName,
        email: email,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );

      await _authRepository.signUp(request);

      state = state.copyWith(
        isLoading: false,
        phoneNumber: phoneNumber,
      );

      return true;
    } on BadRequestException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred. Please try again.',
      );
      return false;
    }
  }

  /// Request OTP for sign in
  Future<bool> requestOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, clearError: true, clearOtp: true);

    try {
      final response = await _authRepository.requestOtp(phoneNumber);

      state = state.copyWith(
        isLoading: false,
        phoneNumber: phoneNumber,
        otpCode: response.otpCode, // Will be null in production
      );

      return true;
    } on NotFoundException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to send OTP. Please try again.',
      );
      return false;
    }
  }

  /// Verify OTP and sign in
  Future<bool> verifyOtp(String otp) async {
    if (state.phoneNumber == null) {
      state = state.copyWith(
        error: 'Phone number not found. Please request OTP again.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _authRepository.verifyOtp(state.phoneNumber!, otp);

      // Get user profile after successful sign in
      final user = await _authRepository.getProfile();

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
        clearOtp: true,
      );

      return true;
    } on UnauthorizedException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to verify OTP. Please try again.',
      );
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _authRepository.signOut();
    state = const AuthState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Refresh user profile
  Future<void> refreshProfile() async {
    try {
      final user = await _authRepository.getProfile();
      state = state.copyWith(user: user);
    } catch (e) {
      // Ignore error, keep current state
    }
  }

  /// Update user profile (name, email, gender, date of birth)
  Future<bool> updateProfile({
    String? fullName,
    String? email,
    String? gender,
    String? dateOfBirth,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final request = UpdateProfileRequest(
        fullName: fullName,
        email: email,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );

      final response = await _authRepository.updateProfile(request);

      state = state.copyWith(
        isLoading: false,
        user: response.user,
      );

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update profile. Please try again.',
      );
      return false;
    }
  }
}

/// Provider for auth state
final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthStateNotifier(authRepository);
});
