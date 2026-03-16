// All API base URL and endpoint paths in one place.
// Only update baseUrl when backend provides a new URL.
class ApiConstants {
  // Base URL from backend — includes /api/v1 prefix
  static const String baseUrl = 'https://thing-respective-sixth-rocky.trycloudflare.com/api/v1';

  // Auth endpoints
  static const String signIn         = '/auth/sign-in';
  static const String signUp         = '/auth/sign-up';
  static const String signOut        = '/auth/sign-out';
  static const String refreshToken   = '/auth/refresh';
  static const String getProfile     = '/auth/profile';
  static const String changePassword = '/auth/change-password';

  // Request timeout duration
  static const Duration timeout = Duration(seconds: 30);
}