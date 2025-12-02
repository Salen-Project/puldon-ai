/// API Endpoints for Puldon Backend
/// Base URL: https://151.245.140.91
class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'https://151.245.140.91';

  // Authentication Endpoints
  static const String signUp = '/auth/signup';
  static const String requestOtp = '/auth/signin/request-otp';
  static const String verifyOtp = '/auth/signin/verify-otp';
  static const String getProfile = '/auth/profile';
  static const String updateProfile = '/auth/profile';
  static const String requestPhoneUpdateOtp = '/auth/profile/phone/request-otp';
  static const String verifyPhoneUpdateOtp = '/auth/profile/phone/verify-otp';

  // Dashboard Endpoint
  static const String dashboard = '/dashboard';

  // Chat Endpoints
  static const String chat = '/chat';
  static String chatHistory(String threadId) => '/chat/history/$threadId';
  static const String speechToText = '/chat/speech-to-text';
  static const String clearChat = '/chat/clear';

  // Expenses Endpoints
  static const String expenses = '/expenses';
  static const String expensesSummary = '/expenses/summary';

  // Goals Endpoints
  static const String goals = '/goals';
  static String goalDetail(String goalId) => '/goals/$goalId';
  static String updateGoal(String goalId) => '/goals/$goalId';
  static String deleteGoal(String goalId) => '/goals/$goalId';
  static String updateGoalProgress(String goalId) => '/goals/$goalId/progress';

  // Debts Endpoints
  static const String debts = '/debts';
  static const String debtsSummary = '/debts/summary';

  // Health Check
  static const String health = '/health';
}
