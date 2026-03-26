class ApiConstants {
  static const String baseUrl = 'https://api.pitstop.ahdus.de/api/v1';

  // Auth endpoints
  static const String signIn         = '/auth/sign-in';
  static const String signUp         = '/auth/sign-up';
  static const String signOut        = '/auth/sign-out';
  static const String refreshToken   = '/auth/refresh';
  static const String getProfile     = '/auth/profile';
  static const String changePassword = '/auth/change-password';

  // Events endpoints — crmId is dynamic, passed at runtime
  static String getEvents(String crmId) => '/crms/$crmId/events';
  static String getEventById(String crmId, String eventId) =>
      '/crms/$crmId/events/$eventId';

  static const Duration timeout = Duration(seconds: 30);
}